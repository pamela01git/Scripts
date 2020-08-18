declare @TABLENAME VARCHAR(50) 
set  @TABLENAME= 'BMS_ACC_ACCOUNT_tX'

DECLARE @OBJECT_ID INT =(SELECT OBJECT_ID('DBO.BMS_ACC_ACCOUNT_tX'))

IF OBJECT_ID('tempdb..#tbl_maintain_info') is not null drop table #tbl_maintain_info

SELECT ix.name as index_name,s.name as [schema_name],t.name as table_name,ps.avg_fragmentation_in_percent,pc.partition_count ,ps.partition_number,alloc_unit_type_desc,total_page
,ROW_NUMBER() OVER (PARTITION BY t.name,ix.name ORDER BY avg_fragmentation_in_percent DESC  ) AS ROWNO

--INTO #tbl_maintain_info
FROM   sys.indexes AS ix WITH (NOLOCK)
       INNER JOIN sys.tables t WITH (NOLOCK) ON     t.object_id = ix.object_id
       INNER JOIN sys.schemas s WITH (NOLOCK)  ON     t.schema_id = s.schema_id
       INNER JOIN
              (SELECT object_id                   ,
                      index_id                    ,
                      avg_fragmentation_in_percent,
                      partition_number,
                      alloc_unit_type_desc,
					  avg_record_size_in_bytes 
              FROM    sys.dm_db_index_physical_stats (DB_ID(), @OBJECT_ID, NULL, NULL, NULL) 
              ) ps ON     t.object_id = ps.object_id AND ix.index_id = ps.index_id
       INNER JOIN
              (SELECT  object_id,
                       index_id ,
                       COUNT(DISTINCT partition_number) AS partition_count,
                       SUM(S3.total_pages) as total_page
              FROM     sys.partitions S2 WITH (NOLOCK)
                   INNER JOIN sys.allocation_units S3 WITH (NOLOCK) ON S3.container_id =CASE WHEN S3.TYPE IN (1,3) THEN S2.hobt_id WHEN S3.TYPE=2 THEN partition_id END 
              GROUP BY object_id,
                       index_id
              ) pc  ON     t.object_id = pc.object_id AND ix.index_id = pc.index_id
WHERE -- ps.avg_fragmentation_in_percent > 30
  --AND 
  ix.name IS NOT NULL
  AND (t.name = @TABLENAME or 'all' = @TABLENAME )
  AND avg_fragmentation_in_percent > 0
  AND ix.name = 'BMS_ACC_ACCOUNT_TX_IDX4_ACC_ID_TX_TIME'
