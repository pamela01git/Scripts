SET @SQL  = 'SELECT @P_NO= $PARTITION.'+@PARTITION_FUNCTION+'(CONVERT([bigint],'''+RIGHT(CONVERT(CHAR(8),@DATE_TO_MOVE,112),6)+'''+''0000000000000''))'

Exec sp_executesql @SQL,N'@P_NO INT OUTPUT',@P_NO=@FG_NO OUT;  
