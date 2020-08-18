set nocount on
  
declare @ProcName nvarchar(100) 
declare @ProcSortOrder int
declare @MyCursor CURSOR   
declare @ProcUser varchar(100)

 select @ProcUser = 'my user'

   declare @StoredProcs TABLE
   (
     SortOrder int,
     ProcedureName varchar(100),
ProcedureCode varchar(7500)
   )

 Insert Into @StoredProcs
  select 0,upper(SysObjects.Name),SysComments.Text
   from SysObjects,SysComments   
  where SysObjects.type='P'
    and (SysObjects.Category = 0)
    and (SysObjects.ID = SysComments.ID) 
    order by SysObjects.Name ASC
 
set nocount off

SET @MyCursor = CURSOR FAST_FORWARD 
FOR 
select ProcedureName,
        SortOrder =  (select count(*)
                        from @StoredProcs B
                        WHERE (A.ProcedureName <> B.ProcedureName)
                          and (REPLACE(UPPER(B.ProcedureCode),B.ProcedureName,'')
                               LIKE '%' + upper(A.ProcedureName) + '%')
                      )
    from @StoredProcs A 
    order by SortOrder Desc
   
OPEN @MyCursor 
FETCH NEXT FROM @MyCursor 
INTO @ProcName,@ProcSortOrder 

   WHILE @@FETCH_STATUS = 0 
   BEGIN 

      PRINT 'if exists (select * from dbo.sysobjects '
      PRINT ' where id = object_id(N' + char(39) + '[dbo].[' + @ProcName + ']' + char(39) + ')'
      PRINT ' and OBJECTPROPERTY(id, N' + char(39) + 'IsProcedure' + char(39) + ') = 1) '
      PRINT ' drop procedure ' + @ProcName  
      PRINT ' GO '
      PRINT ' SET QUOTED_IDENTIFIER OFF '
      PRINT ' GO '
      PRINT ' SET ANSI_NULLS OFF ' 
      PRINT ' GO'
      exec sp_helptext @ProcName
      PRINT ' GO '
      PRINT ' SET QUOTED_IDENTIFIER OFF '
      PRINT ' GO '
      PRINT ' SET ANSI_NULLS ON ' 
      PRINT ' GO '
      PRINT ' GRANT  EXECUTE  ON [dbo].[' + @ProcName + ']  TO [' + @ProcUser + ']'
      PRINT ' GO '

   /*   PRINT @ProcName + '  ' + cast(@ProcSortOrder as varchar(20)) */
      FETCH NEXT FROM @MyCursor 
INTO @ProcName,@ProcSortOrder   
   END 

CLOSE @MyCursor 
DEALLOCATE @MyCursor