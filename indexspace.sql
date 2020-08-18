            SELECT s4.name,SUM(S3.TOTAL_PAGES)
                               --@CONVERT(VARCHAR,SUM(S3.TOTAL_PAGES))
                              FROM  sys.tables S1
                               INNER JOIN sys.partitions S2 ON S1.object_id=S2.OBJECT_ID
                               INNER JOIN sys.allocation_units S3 ON S3.container_id =CASE WHEN S3.TYPE IN (1,3) THEN S2.hobt_id WHEN S3.TYPE=2 THEN partition_id END
                               INNER JOIN sys.indexes s4 on (s4.object_id=S2.object_id and s4.index_id=S2.index_id)
                              WHERE S1.name= 'S_EVT_ACT'