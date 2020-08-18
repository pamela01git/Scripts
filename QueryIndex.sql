	use dmscm
	SELECT IC.INDEX_ID as IND_ID
	      ,IC.KEY_ORDINAL as KEY_NO
	      ,T.[NAME] as TABLE_NAME
	      ,C.[NAME] as COL_NAME
	      ,I.NAME as PK_NAME
	      ,S.NAME as GROUP_NAME
		    ,CASE WHEN k.type = 'PK' THEN 'PK' ELSE 'IDX' END as COL_TYPE
			,k.type 
		  ,I.TYPE_DESC as IDX_TYPE
		  ,Partition_Ordinal as Partition_Ordinal
		  ,I.Filter_Definition as Filter_Definition
		  ,CASE WHEN IndexProperty(i.object_id, i.name, 'IsUnique') = '1' THEN 'UNIQUE' ELSE '' END as IsUnique
		  ,I.fill_factor as Fill_Factor
		  ,(SELECT MAX(data_compression_desc) FROM sys.partitions WHERE OBJECT_ID=t.OBJECT_ID AND index_id =ic.index_id) as Compression_Desc
		  ,CASE WHEN ic.IS_DESCENDING_KEY = 0 THEN 'ASC' ELSE 'DESC' END ORDER_TYPE
		  ,IC.IS_INCLUDED_COLUMN AS IS_INCLUDED_COLUMN
		 
	FROM  SYS.TABLES T
	  INNER JOIN sys.index_columns as ic ON (ic.object_id = t.object_id)
	  INNER JOIN sys.indexes AS I ON (i.object_id = ic.object_id AND i.index_id = ic.index_id )            
	  INNER JOIN sys.data_spaces S ON (S.data_space_id = i.data_space_id)
	  INNER JOIN sys.columns c on (c.object_id = t.object_id and c.column_id = ic.column_id )
	  LEFT JOIN sys.key_constraints K ON (t.object_id = k.parent_object_id and I.name=K.name) 
	WHERE I.NAME IS NOT NULL
      AND I.is_hypothetical =0
	  AND k.type is null
	ORDER BY  ic.index_id,ic.key_ordinal