USE [master]
GO

/****** Object:  StoredProcedure [dbo].[SP_Change_DB_Login]    Script Date: 8/23/2012 8:43:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_Change_DB_Login]
@DbName char(30) 
As


Declare @Ins_SQL  nvarchar(max)
declare @Login_SQL nvarchar(max)
declare @Change_SQL nvarchar(max)
DECLARE @ERROR_MESSAGE  NVARCHAR(4000)
declare @User_Name sysname
declare @issqluser char(1)

---------------------------------------------------
-- STEP 1: Inset Dir to temp table
---------------------------------------------------

--Check for existance of temporary table #tblTempRestore
if object_id('tempdb..##tblTempSysUser') > 0 drop table ##tblTempSysUser
create table ##tblTempSysUser ([User_Name] sysname,issqluser char(1))


set @Ins_SQL =
'USE '+RTRIM(@DbName)+'
insert into ##tblTempSysUser   select name,issqluser from (SELECT name,issqluser
  ,row_number() over(partition by upper(name) order by updatedate desc ) as rowno
FROM sys.sysusers
WHERE GID=0 AND UID>4) a
where rowno = 1'

BEGIN TRY
  --print @Ins_SQL
  EXECUTE sp_executesql @Ins_SQL
END TRY
BEGIN CATCH      
  SET @ERROR_MESSAGE=ERROR_MESSAGE() 
  RAISERROR(@ERROR_MESSAGE,16,1); 
  GOTO Main_Exit;
 END CATCH  
      
---------------------------------------------------
-- STEP 2: Restore & Move Dir
---------------------------------------------------

DECLARE UserInfo CURSOR LOCAL FOR
select [User_Name],issqluser from  ##tblTempSysUser;
		      
 OPEN UserInfo;
   FETCH NEXT FROM UserInfo 
     INTO @User_Name,@issqluser
	 WHILE @@FETCH_STATUS = 0 
	   BEGIN
	   
	    set @Login_SQL = 'IF not exists( select * from master.sys.syslogins WHERE loginname=N'''+RTRIM(@User_Name)+''')
	                       begin
	                          if '''+rtrim(@issqluser)+''' = ''1'' 
	                          begin 
	                            use master  CREATE LOGIN ['+RTRIM(@User_Name)+'] WITH password=N'''+RTRIM(@User_Name)+''',DEFAULT_DATABASE=['+RTRIM(@DbName)+'], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
	                           END ELSE BEGIN
	                            use master CREATE LOGIN ['+RTRIM(@User_Name)+'] FROM WINDOWS WITH DEFAULT_DATABASE=['+RTRIM(@DbName)+']
	                           END
	                      end'

         set @Change_SQL= 'USE '+RTRIM(@DbName)+'
                EXEC sp_change_users_login @Action =''Update_One'', @UserNamePattern='''+RTRIM(@User_Name)+''',@LoginName='''+RTRIM(@User_Name)+''';'

        BEGIN TRY
         print @Login_SQL
         
         EXECUTE sp_executesql  @Login_SQL  
         if @issqluser = '1'
          begin 
            print @Change_SQL
            EXECUTE sp_executesql  @Change_SQL
          end
        END TRY
        BEGIN CATCH      
          SET @ERROR_MESSAGE=ERROR_MESSAGE() 
          RAISERROR(@ERROR_MESSAGE,16,1); 
          GOTO Main_Exit;
        END CATCH  

         FETCH NEXT FROM UserInfo
           INTO @User_Name,@issqluser
	   END 
  CLOSE UserInfo;                                                                                                                     
 DEALLOCATE UserInfo;
 
------------------------------
-- Exit
   Main_Exit:
------------------------------

GO

