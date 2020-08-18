declare @TABLE_NAME SYSNAME
       ,@PK_LIST VARCHAR(1000)
       ,@SQL NVARCHAR(MAX)
DECLARE TableList CURSOR LOCAL FOR
select distinct table_name
from dbo.tablecolumn_info
where IS_PK= 'yes'  AND CHECK_FLAG IS NULL
		      
 OPEN TableList;
   FETCH NEXT FROM  TableList
     INTO @TABLE_NAME
	 WHILE @@FETCH_STATUS = 0 
	   BEGIN
	   
	     SET @PK_LIST= ''
	     SELECT @PK_LIST = @PK_LIST + ',' +COLUMN_NAME
	     FROM dbo.TableColumn_Info
	     WHERE TABLE_NAME= @TABLE_NAME
	       AND IS_PK= 'YES'
	     ORDER BY ORDINAL_POSITION  DESC
	     
	     SET @PK_LIST= SUBSTRING(@PK_LIST,2,8000)
	     
	     SET @SQL= 'SELECT TOP 1 * FROM (SELECT '+RTRIM(@PK_LIST)+' FROM '+RTRIM(@TABLE_NAME)+' GROUP BY '+RTRIM(@PK_LIST)+' HAVING COUNT(1)> 1) AS A; 
	         IF (SELECT @@ROWCOUNT) = 0 
	          begin
	             UPDATE dbo.TableColumn_Info
	             SET CHECK_FLAG = ''OK''
	             WHERE TABLE_NAME = '''+RTRIM(@TABLE_NAME)+'''
	         END else begin 
	          	 UPDATE dbo.TableColumn_Info
	             SET CHECK_FLAG = ''FAILED''
	             WHERE TABLE_NAME = '''+RTRIM(@TABLE_NAME)+'''
	          end'
	     PRINT @SQL

         FETCH NEXT FROM TableList
           INTO @TABLE_NAME
	   END 
  CLOSE TableList;                                                                                                                     
 DEALLOCATE TableList;