      SELECT OBJECT_NAME(f.parent_object_id) AS TableName
            ,SCHEMA_NAME(f.SCHEMA_ID) AS SchemaName
            ,f.name AS ForeignKey
            ,COL_NAME(fc.parent_object_id,fc.parent_column_id) AS ColumnName
            ,OBJECT_NAME (f.referenced_object_id) AS ReferenceTableName
            ,(SELECT SCHEMA_NAME(SCHEMA_ID) FROM SYS.TABLES WHERE OBJECT_ID=f.referenced_object_id) as ReferenceSchema
            ,COL_NAME(fc.referenced_object_id,fc.referenced_column_id) AS ReferenceColumnName
            ,CASE WHEN DELETE_REFERENTIAL_ACTION=1 THEN 'ON DELETE '+RTRIM(DELETE_REFERENTIAL_ACTION_DESC) ELSE '' END AS DELETE_REFERENTIAL_ACTION
            ,CASE WHEN UPDATE_REFERENTIAL_ACTION=1 THEN 'ON UPDATE '+RTRIM(UPDATE_REFERENTIAL_ACTION_DESC) ELSE '' END AS UPDATE_REFERENTIAL_ACTION
      FROM sys.foreign_keys AS f
        INNER JOIN sys.foreign_key_columns AS fc ON (f.OBJECT_ID = fc.constraint_object_id)
		order by 1