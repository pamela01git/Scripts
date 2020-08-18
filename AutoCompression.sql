
with CTE_SIZE AS (
select * from (
SELECT A.NAME AS Table_Name,D.NAME as index_name,sum(C.TOTAL_PAGES)*8/1024.00 AS Table_SIZE,sum(c.total_pages*8.00)/case when max(D.rowcnt)=0 then 1 else max(D.rowcnt) end  as 'PerSize KB',max(d.rowcnt) as cnt
 FROM  SYSOBJECTS A
JOIN sys.partitions B ON A.ID=B.OBJECT_ID
JOIN SYS.SYSINDEXES D ON B.OBJECT_ID=D.ID AND B.INDEX_ID=D.INDID
JOIN sys.allocation_units C ON C.container_id =CASE WHEN C.TYPE IN (1,3) THEN B.hobt_id WHEN C.TYPE=2 THEN partition_id END
WHERE A.XTYPE='U' --and a.name='fb_acct1pf_mh'
GROUP BY A.NAME,d.name
 ) t1
where table_size > 150 and table_name not like 'z%'
),
 CTE_TABLE AS (
   SELECT s2.name,case when max(PARTITION_NUMBER)= 1 then 'N' else 'Y' end Partition_Flag
                           ,case when max(s1.data_compression_desc)='NONE' then 'N' else 'Y' end Compression_Flag
                            FROM sys.partitions S1
                                 INNER JOIN SYS.TABLES S2 ON (S1.OBJECT_ID=S2.OBJECT_ID)
                            where S2.create_date > '20091201'     
                           group by S2.name
 )

 SELECT *,CASE WHEN S2.index_name LIKE 'ID%' THEN 'ALTER INDEX '+S2.index_name +' ON DBO.'+S1.NAME +' REBUILD WITH (DATA_COMPRESSION = PAGE )' ELSE
  'ALTER TABLE DBO.'+S1.NAME +' REBUILD WITH (DATA_COMPRESSION = PAGE); ' END fROM CTE_TABLE S1 INNER JOIN CTE_SIZE S2 ON (S1.NAME=S2.Table_Name)
 WHERE S1.Compression_Flag = 'N'
 ORDER BY 1