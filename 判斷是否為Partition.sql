SELECT
    OBJECT_NAME(i.object_id) AS TableName,
    CASE WHEN ps.data_space_id IS NOT NULL THEN 'paritioned' ELSE 'not
partitioned' END,
    COALESCE(ps.name, fg.name) AS PartitionScheme_or_Filegroup
FROM sys.indexes AS i
JOIN sys.data_spaces AS ds ON
    ds.data_space_id = i.data_space_id
LEFT JOIN sys.partition_schemes AS ps ON
    ps.data_space_id = ds.data_space_id
LEFT JOIN sys.filegroups AS fg ON
    fg.data_space_id = i.data_space_id
WHERE
    OBJECTPROPERTY(i.object_id, 'ISMSShipped') = 0
