SELECT c.name 'ColumnName', tbl.name 'TableName',  
 	   c.is_masked 'IsMasked', c.masking_function 'MaskingFunction' 
 FROM sys.masked_columns AS c 
 JOIN sys.tables AS tbl  
 ON c.[object_id] = tbl.[object_id] 
 WHERE is_masked = 1; 
