SELECT A.name AS Table_Name,CAST(sum(C.total_pages)*8/1024.00 AS CHAR(20)) +' MB' AS Table_SIZE
 FROM  sysobjects A
JOIN sys.partitions B ON A.id=B.object_id
JOIN sys.allocation_units C ON C.container_id =CASE WHEN C.type IN (1,3) THEN B.hobt_id WHEN C.type=2 THEN partition_id END
WHERE A.xtype='U' 
GROUP BY A.name
order by sum(C.total_pages)*8/1024.00 desc



/* 物件使用空間 */
SELECT A.NAME AS Table_Name,CAST(sum(C.TOTAL_PAGES)*8/1024.00 AS CHAR(20)) +' MB' AS Table_SIZE,sum(c.total_pages*8.00)/ case when max(D.rowcnt)=0 then 1 else max(D.rowcnt) end as 'PerSize KB',max(d.rowcnt) as cnt
 FROM  SYSOBJECTS A
JOIN sys.partitions B ON A.ID=B.OBJECT_ID
JOIN SYS.SYSINDEXES D ON B.OBJECT_ID=D.ID AND B.INDEX_ID=D.INDID
JOIN sys.allocation_units C ON C.container_id =CASE WHEN C.TYPE IN (1,3) THEN B.hobt_id WHEN C.TYPE=2 THEN partition_id END
WHERE A.XTYPE='U' --and a.name='cb_product'
GROUP BY A.NAME
/* 物件(data+index) 使用空間 */
SELECT A.NAME AS Table_Name,D.NAME as index_name,CAST(sum(C.TOTAL_PAGES)*8/1024.00 AS CHAR(20)) +' MB' AS Table_SIZE,sum(c.total_pages*8.00)/case when max(D.rowcnt)=0 then 1 else max(D.rowcnt) end  as 'PerSize KB',max(d.rowcnt) as cnt
 FROM  SYSOBJECTS A
JOIN sys.partitions B ON A.ID=B.OBJECT_ID
JOIN SYS.SYSINDEXES D ON B.OBJECT_ID=D.ID AND B.INDEX_ID=D.INDID
JOIN sys.allocation_units C ON C.container_id =CASE WHEN C.TYPE IN (1,3) THEN B.hobt_id WHEN C.TYPE=2 THEN partition_id END
WHERE A.XTYPE='U' --and a.name='fb_acct1pf_mh'
GROUP BY A.NAME,d.name

/* 物件(data+index) 使用空間 */
SELECT A.NAME AS Table_Name,D.NAME as index_name,sum(C.TOTAL_PAGES)*8/1024.00  AS Table_SIZE,sum(c.total_pages*8.00)/case when max(D.rowcnt)=0 then 1 else max(D.rowcnt) end  as 'PerSize KB',max(d.rowcnt) as cnt
 FROM  SYSOBJECTS A
JOIN sys.partitions B ON A.ID=B.OBJECT_ID
JOIN SYS.SYSINDEXES D ON B.OBJECT_ID=D.ID AND B.INDEX_ID=D.INDID
JOIN sys.allocation_units C ON C.container_id =CASE WHEN C.TYPE IN (1,3) THEN B.hobt_id WHEN C.TYPE=2 THEN partition_id END
WHERE A.XTYPE='U' --and a.name='fb_acct1pf_mh'
GROUP BY A.NAME,d.name
order by 3 desc
 

declare @tbname varchar(100)
set @tbname='dbo.BMS_RAT_TX_BATCH'
SELECT
    i.name                  AS IndexName,
    SUM(s.used_page_count) * 8   AS IndexSizeKB
FROM sys.dm_db_partition_stats  AS s 
JOIN sys.indexes                AS i
ON s.[object_id] = i.[object_id] AND s.index_id = i.index_id
WHERE s.[object_id] = object_id(@tbname)
GROUP BY i.name
ORDER BY 2
