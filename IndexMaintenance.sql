declare @TABLENAME VARCHAR(50) 
set  @TABLENAME= 'all'

IF OBJECT_ID('tempdb..#tbl_maintain_info') > 0 drop table #tbl_maintain_info

SELECT ix.name as index_name,s.name as [schema_name],t.name as table_name,ps.avg_fragmentation_in_percent,pc.partition_count ,ps.partition_number,alloc_unit_type_desc,TOTAL_PAGES
INTO #tbl_maintain_info
FROM   sys.indexes AS ix
       INNER JOIN sys.tables t ON     t.object_id = ix.object_id
       INNER JOIN sys.schemas s ON     t.schema_id = s.schema_id
       INNER JOIN
              (SELECT object_id                   ,
                      index_id                    ,
                      avg_fragmentation_in_percent,
                      partition_number,
                      alloc_unit_type_desc
              FROM    sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL)
              ) ps ON     t.object_id = ps.object_id AND ix.index_id = ps.index_id
       INNER JOIN
              (SELECT  object_id,
                       index_id ,
                       COUNT(DISTINCT partition_number) AS partition_count,
                       SUM(S3.TOTAL_PAGES) as TOTAL_PAGES
              FROM     sys.partitions S2
                   INNER JOIN sys.allocation_units S3 ON S3.container_id =CASE WHEN S3.TYPE IN (1,3) THEN S2.hobt_id WHEN S3.TYPE=2 THEN partition_id END 
              GROUP BY object_id,
                       index_id
              ) pc  ON     t.object_id = pc.object_id AND ix.index_id = pc.index_id
WHERE  ps.avg_fragmentation_in_percent > 15
  AND ix.name IS NOT NULL
  AND (t.name = @TABLENAME or 'all' = @TABLENAME )
  
truncate table master.dbo.RebuildStatus

insert into  master.dbo.RebuildStatus (index_name,table_name,avg_fragmentation_in_percent,total_page)
select index_name,table_name,avg_fragmentation_in_percent,TOTAL_PAGES
from #tbl_maintain_info

  
 ---------------------------------------------------
-- STEP 2: Restore & Move Dir
---------------------------------------------------

declare @index_name sysname
       ,@schema_name sysname
       ,@table_name sysname
       ,@avg_fragmentation_in_percent int
       ,@partition_count int
       ,@partition_number int
       ,@maintain_sql nvarchar(max)
       ,@sub_maintain_sql nvarchar(max)
       ,@ERROR_MESSAGE nvarchar(max)
       ,@alloc_unit_type_desc varchar(30)
       ,@start_time datetime

DECLARE MatainInfo CURSOR LOCAL FOR
select index_name,[schema_name],table_name,avg_fragmentation_in_percent,partition_count ,partition_number,alloc_unit_type_desc
from  #tbl_maintain_info
order by avg_fragmentation_in_percent
		      
 OPEN MatainInfo;
   FETCH NEXT FROM MatainInfo
     INTO @index_name,@schema_name,@table_name,@avg_fragmentation_in_percent,@partition_count ,@partition_number,@alloc_unit_type_desc
	 WHILE @@FETCH_STATUS = 0 
	   BEGIN
	    
	    set @start_time= getdate()
		 		
         SET @sub_maintain_sql = 'ALTER INDEX ['+ rtrim(@index_name)+ '] ON [' + rtrim(@schema_name) + '].[' + rtrim(@table_name) + '] ' +
              CASE WHEN @avg_fragmentation_in_percent >= 15  THEN 'REBUILD ' ELSE 'REORGANIZE' END
              --+CASE WHEN @partition_count > 1 THEN ' PARTITION = ' + CONVERT(VARCHAR,@partition_number) ELSE '' END

         SET @maintain_sql= rtrim(@sub_maintain_sql) +' with (SORT_IN_TEMPDB = ON ,MAXDOP = 1, ONLINE=ON)' 
        BEGIN TRY
        --  PRINT @maintain_sql
          EXECUTE sp_executesql @maintain_sql
        END TRY
        BEGIN CATCH    
          
         IF (ERROR_NUMBER() = 2725) 
          BEGIN 
            SET @maintain_sql= rtrim(@sub_maintain_sql) +' with (SORT_IN_TEMPDB = ON ,MAXDOP = 1, ONLINE=OFF)'
             print @maintain_sql
             --EXECUTE sp_executesql @maintain_sql
          END ELSE BEGIN
            SET @ERROR_MESSAGE=ERROR_MESSAGE() 
            RAISERROR(@ERROR_MESSAGE,16,1); 
            GOTO Main_Exit;
          END 
        END CATCH  
        
                
       update master.dbo.RebuildStatus 
	   set start_time=@start_time, end_time=getdate()
	   where index_name=@index_name

         FETCH NEXT FROM MatainInfo
           INTO @index_name,@schema_name,@table_name,@avg_fragmentation_in_percent,@partition_count ,@partition_number,@alloc_unit_type_desc
	   
	  
	   
	   END 
  CLOSE MatainInfo;                                                                                                                     
 DEALLOCATE MatainInfo; 

------------------------------
-- Exit
   Main_Exit:
------------------------------ 
