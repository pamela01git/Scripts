
	SELECT IC.INDEX_ID as IND_ID
	      ,IC.KEY_ORDINAL as KEY_NO
	      ,T.[NAME] as TABLE_NAME
	      ,C.[NAME] as COL_NAME
	      ,I.NAME as PK_NAME
	      ,S.NAME as GROUP_NAME
		  ,CASE WHEN k.type = 'PK' THEN 'PK' ELSE 'IDX' END as COL_TYPE
		  ,I.TYPE_DESC as IDX_TYPE
		  ,Partition_Ordinal as Partition_Ordinal
		  ,I.Filter_Definition as Filter_Definition
		  ,CASE WHEN IndexProperty(I.object_id, I.name, 'IsUnique') = '1' THEN 'UNIQUE' ELSE '' END as IsUnique
		  ,I.fill_factor as Fill_Factor
		  ,(SELECT MAX(data_compression_desc) FROM sys.partitions WHERE OBJECT_ID=T.OBJECT_ID AND index_id =IC.index_id) as Compression_Desc
		  ,CASE WHEN IC .IS_DESCENDING_KEY = 0 THEN 'ASC' ELSE 'DESC' END ORDER_TYPE
		  ,IC.IS_INCLUDED_COLUMN AS IS_INCLUDED_COLUMN
		  
	FROM  sys.tables T
	  INNER JOIN sys.index_columns as IC ON (IC.object_id = T.object_id)
	  INNER JOIN sys.indexes AS I ON (I.object_id = IC.object_id AND I.index_id = IC.index_id )            
	  INNER JOIN sys.data_spaces S ON (S.data_space_id = I.data_space_id)
	  INNER JOIN sys.columns C on (C.object_id = T.object_id and C.column_id = IC.column_id )
	  LEFT JOIN sys.key_constraints k ON (T.object_id = k.parent_object_id and I.name=k.name) 
	
	WHERE T.schema_id=1
	 and  T.NAME in ('S_EVT_ACT')--,'S_EVT_MAIL','S_SRV_REQ','S_SRV_REQ_X ')
	  AND I.NAME IS NOT NULL
      AND I.is_hypothetical =0
   --  and C.name in ('MAIL_BODY','CREATED')
	ORDER BY  IC.index_id,IC.key_ordinal