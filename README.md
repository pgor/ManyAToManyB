# ManyAToManyB

A sample project to demonstrate a Core Data performance problem.

When using a many-to-many relationship between two entities, there are times when a query is desired to find "orphaned" objects which do not have related objects. The commonly proposed method for this is a predicate of `manyBs.@count == 0` for a given entity `A`. This works well when A-to-B is one-to-many or even (usually) many-to-many. Unfortunately, there are cases where this causes a severe performance penalty: When querying the "wrong way" across a many-to-many relationship.

This app uses a simple A<<->>B Core Data model. It will generate 10,000 of each entity (adjustable via `maxNumRecords` at AppDelegate.m:39) and relates them to each other unless their index is a multiple of 100. This leaves ~1% of both A and B objects "orphaned" for our sample queries to find.

MasterViewController builds predicates into a list to display and select from. Selecting one from the table view will display the results in the DetailViewController, along with the time taken by the query.

### @count

These first two queries use the commonly proposed method of finding orphaned objects. On my iPhone 5, "Unattached As via @count" takes 0.0634sec, and "Unattached Bs via @count" takes 48.7783sec.

### ANY

*THIS QUERY WILL CRASH.* This is an intentionally provided example that the straightforward query to join across the join table is not possible with the current predicate translations.

### NONE

Now that "ANY" is off the table, inverting the logic to the brain-hurting "NONE manyBs != nil" generates queries with fairly symmetric performance of 0.0353sec for A->B and 0.0918sec for B->A.

## Why?

To implement a many-to-many relationship in SQL, Core Data generates a "joining table" (`Z_1MANYBS`) which consists simply of two columns for the primary keys of each (A,B) pair in the many-to-many sets. This table has one compound index, which is exactly what you want when you are joining to both the `A` and `B` tables.

Setting `-com.apple.CoreData.SQLDebug 1` during app execution shows us the queries generated are

```
SELECT 0, t0.Z_PK, t0.Z_OPT, t0.ZNAME FROM ZA t0 WHERE (SELECT COUNT(t1.Z_2MANYBS) FROM Z_1MANYBS t1 WHERE (t0.Z_PK = t1.Z_1MANYAS) ) = ? ORDER BY t0.ZNAME
```

and

```
SELECT 0, t0.Z_PK, t0.Z_OPT, t0.ZNAME FROM ZB t0 WHERE (SELECT COUNT(t1.Z_1MANYAS) FROM Z_1MANYBS t1 WHERE (t0.Z_PK = t1.Z_2MANYBS) ) = ? ORDER BY t0.ZNAME
```

where the `?` is a placeholder for zero. These queries only join the entity and join tables, which is a reasonable optimization to reduce total number of joins. They look almost identical. Unfortunately, when joining from the `B` table, it cannot use the compound index for the `WHERE (t0.Z_PK = t1.Z_2MANYBS)` clause and must resort to a slow table scan.

Changing to the NONE predicate generates queries of:

```
SELECT DISTINCT 0, t0.Z_PK, t0.Z_OPT, t0.ZNAME FROM ZA t0 LEFT OUTER JOIN Z_1MANYBS t1 ON t0.Z_PK = t1.Z_1MANYAS WHERE  NOT (  t1.Z_2MANYBS IS NOT NULL) ORDER BY t0.ZNAME
```

and 

```
SELECT DISTINCT 0, t0.Z_PK, t0.Z_OPT, t0.ZNAME FROM ZB t0 LEFT OUTER JOIN Z_1MANYBS t1 ON t0.Z_PK = t1.Z_2MANYBS WHERE  NOT (  t1.Z_1MANYAS IS NOT NULL) ORDER BY t0.ZNAME
```

Both of these queries examine the values of both `Z_1MANYAS` and `Z_2MANYBS` in the join table, allowing them both to use the compound index. Thus, we gain predictably symmetric query performance.


## Apple Bug Reports

* Performance Issue: [Apple rdar://20924980](rdar://20924980) | [Open Radar](http://www.openradar.me/radar?id=4935382823075840)
* Enable "ALL manyBs == nil" Predicate: [Apple rdar://20926315](rdar://20926315) | [Open Radar](http://www.openradar.me/radar?id=6705001254617088)


*pgor, 12may15*

