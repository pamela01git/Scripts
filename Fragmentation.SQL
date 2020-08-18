-- �˵����w��Ʈw�����C�@�ӯ��ޤ����q(fragmentation)��T�A�p�U�G
 SELECT sch.name N'���c�y�z', obj.name N'��ƪ�', inx.name AS N'���ަW��', index_type_desc N'��������', avg_fragmentation_in_percent '���q(%)'
 , avg_page_space_used_in_percent N'�������M��(%)', fragment_count, avg_fragment_size_in_pages, page_count 
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