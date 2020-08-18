-- 檢視指定資料庫內的每一個索引之片段(fragmentation)資訊，如下：
 SELECT sch.name N'結構描述', obj.name N'資料表', inx.name AS N'索引名稱', index_type_desc N'索引類型', avg_fragmentation_in_percent '片段(%)'
 , avg_page_space_used_in_percent N'頁面飽和度(%)', fragment_count, avg_fragment_size_in_pages, page_count 
 FROM sys.dm_db_index_physical_stats (DB_ID(), NULL,NULL, NULL, 'SAMPLED') AS phy 
 INNER JOIN sys.indexes AS inx ON phy.object_id = inx.object_id AND phy.index_id = inx.index_id
  INNER JOIN sys.objects AS obj ON phy.object_id = obj.object_id 
  INNER JOIN sys.schemas AS sch ON obj.schema_id = sch.schema_id 
  WHERE --index_type_desc <> 'HEAP'  AND
    fragment_count IS NOT NULL AND avg_fragment_size_in_pages IS NOT NULL
 ORDER BY 2
 
 SELECT OBJECT_NAME(OBJECT_ID), index_id,index_type_desc,index_level,
avg_fragmentation_in_percent,avg_page_space_used_in_percent,page_count
FROM sys.dm_db_index_physical_stats
(DB_ID(), NULL, NULL, NULL , 'SAMPLED')
ORDER BY avg_fragmentation_in_percent DESC
