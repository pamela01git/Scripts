 USE BMSDB
 GO
 DECLARE @TABLE_NAME SYSNAME = ''
 ,@SUFFIX SYSNAME
 ,@FG_NAME SYSNAME
 ,@PrintFg char(1) = 0  -- 程式碼列印記號, 預設不列印程式


DECLARE @PAR_COL SYSNAME
DECLARE @PAR_FG_NAME SYSNAME
DECLARE @IDX_SCRIPT NVARCHAR(MAX) = ''
DECLARE @ERR_NO int
DECLARE @ERROR_MESSAGE  NVARCHAR(4000)
DECLARE @UPD_CNT INT = 0




declare    @IncludeFileGroup  bit = 1,
    @IncludeDrop       bit = 1,
    @IncludeFillFactor bit = 1

    -- Get all existing indexes, but NOT the primary keys
    DECLARE Indexes_cursor CURSOR
        FOR SELECT SC.Name          AS      SchemaName,
                   SO.Name          AS      TableName,
                   SI.OBJECT_ID     AS      TableId,
                   SI.[Name]         AS  IndexName,
                   SI.Index_ID       AS  IndexId,
                   FG.[Name]       AS FileGroupName,
                   CASE WHEN SI.Fill_Factor = 0 THEN 100 ELSE SI.Fill_Factor END  Fill_Factor,
				   SI.has_filter  AS FILTER,
				   SI.Filter_Definition AS Filter_Definition
              FROM sys.indexes SI  WITH (NOLOCK)
              LEFT JOIN sys.data_spaces FG  WITH (NOLOCK)
                     ON SI.data_space_id = FG.data_space_id
              INNER JOIN sys.objects SO  WITH (NOLOCK)
                      ON SI.OBJECT_ID = SO.OBJECT_ID
              INNER JOIN sys.schemas SC  WITH (NOLOCK)
                      ON SC.schema_id = SO.schema_id
             WHERE OBJECTPROPERTY(SI.OBJECT_ID, 'IsUserTable') = 1
               AND SI.[Name] IS NOT NULL
              -- AND SI.is_primary_key = 0
               AND SI.is_unique_constraint = 0
               AND INDEXPROPERTY(SI.OBJECT_ID, SI.[Name], 'IsStatistics') = 0
			  and (so.name= @TABLE_NAME OR @TABLE_NAME = '')
             ORDER BY OBJECT_NAME(SI.OBJECT_ID), SI.Index_ID

    DECLARE @SchemaName     sysname
    DECLARE @TableName      sysname
    DECLARE @TableId        int
    DECLARE @IndexName      sysname
    DECLARE @FileGroupName  sysname
    DECLARE @IndexId        int
    DECLARE @FillFactor     int
	DECLARE @FILTER          INT
	DECLARE @Filter_Definition SYSNAME

    DECLARE @NewLine nvarchar(4000)
    SET @NewLine = char(13) + char(10)
    DECLARE @Tab  nvarchar(4000)
    SET @Tab = SPACE(4)
	

    -- Loop through all indexes
    OPEN Indexes_cursor

    FETCH NEXT
     FROM Indexes_cursor
     INTO @SchemaName, @TableName, @TableId, @IndexName, @IndexId, @FileGroupName, @FillFactor,@FILTER,@Filter_Definition

	 

    WHILE (@@FETCH_STATUS = 0)
        BEGIN


		SET @UPD_CNT = 0

            -- Get all columns of the index
            DECLARE IndexColumns_cursor CURSOR
                FOR SELECT SC.[Name],
                           IC.[is_included_column],
                           IC.is_descending_key
                      FROM sys.index_columns IC  WITH (NOLOCK)
                     INNER JOIN sys.columns SC  WITH (NOLOCK)
                             ON IC.OBJECT_ID = SC.OBJECT_ID
                            AND IC.Column_ID = SC.Column_ID
                     WHERE IC.OBJECT_ID =@TableId
                       AND Index_ID =@IndexId
					   AND NOT(IC.Partition_Ordinal = 1 AND IC.KEY_ORDINAL = 0)
					   AND (SC.user_type_id IN (40,42,61) OR SC.column_id = 1 )
                     ORDER BY IC.[is_included_column],
                              IC.key_ordinal

            DECLARE @IxColumn      sysname
            DECLARE @IxIncl        bit
            DECLARE @Desc          bit
            DECLARE @IxIsIncl      bit
            SET @IxIsIncl = 0
            DECLARE @IxFirstColumn   bit
            SET @IxFirstColumn = 1


            -- Loop through all columns of the index and append them to the CREATE statement
            OPEN IndexColumns_cursor
            FETCH NEXT
             FROM IndexColumns_cursor
             INTO @IxColumn, @IxIncl, @Desc

			   

            WHILE (@@FETCH_STATUS = 0)
                BEGIN

					  SET @UPD_CNT = @UPD_CNT + 1
					    
                    FETCH NEXT
                     FROM IndexColumns_cursor
                     INTO @IxColumn, @IxIncl, @Desc
                END
            --END WHILE
            CLOSE IndexColumns_cursor
            DEALLOCATE IndexColumns_cursor

			IF @UPD_CNT >0 PRINT 'UPDATE STATISTICS '+@TableName+' '+@IndexName

			--UPDATE STATISTICS Sales.SalesOrderDetail AK_SalesOrderDetail_rowguid;

            FETCH NEXT
             FROM Indexes_cursor
             INTO @SchemaName, @TableName, @TableId, @IndexName, @IndexId, @FileGroupName, @FillFactor,@FILTER,@Filter_Definition
        END
    --END WHILE
    CLOSE Indexes_cursor
    DEALLOCATE Indexes_cursor





