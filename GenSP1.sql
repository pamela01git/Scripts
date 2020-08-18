
----------------------------------------------------------------------------------------------

--SOURCE

----------------------------------------------------------------------------------------------

 

--create a table to record the results...

if exists (select * from dbo.sysobjects where id = object_id(N'[StoredProcs]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)

drop table [StoredProcs]

GO

create table StoredProcs(

     SortOrder int,

             ProcedureId int,

     ProcedureName varchar(100),

     ProcedureCode varchar(7500),

             NbRuns smallint,

             Type varchar(2)

   )

GO

set nocount on

  

            -----------------------------------------------

            --get all stored procs and functions names

            --we remove the name of the stored proc from the code and we also remove comments

            -----------------------------------------------

            insert Into StoredProcs 

            select 0,SysObjects.ID,upper(SysObjects.Name),

                        dbo.StripSQLComments (replace(upper(SysComments.Text),upper(SysObjects.Name),'')),0,

                        case SysObjects.type when 'P' then 'P' else 'F' end 

            from SysObjects, SysComments

            where SysObjects.type IN ('P','FN', 'IF', 'TF') --PROCS & FC

            and SysObjects.ID = SysComments.ID 

            and (SysObjects.Category = 0)

            and upper(SysObjects.Name) not like 'SP_SEL_%'

 

            -----------------------------------------------

            --get position

            -----------------------------------------------

            declare @m_ProcedureName varchar(100)

            declare @m_dependencies smallint 

 

            --only to start

--          select @m_ProcedureName = min (ProcedureName) from StoredProcs

 

            select @m_ProcedureName = 'DRP_PLANNING_EXECUTE_PRODUCTID'

            --condition on nbRuns to avoid unexpected infinite loops

            while ((select count(*) from StoredProcs where SortOrder = 0) > 0

                                     and (select max(NbRuns) from StoredProcs )< 15)

            begin

                        select @m_dependencies = count(*)

        from StoredProcs THIS, StoredProcs OTHERS

        WHERE (THIS.ProcedureName <> OTHERS.ProcedureName)

        and (THIS.ProcedureCode LIKE '%' + upper(OTHERS.ProcedureName) + '%')

                        and OTHERS.SortOrder = 0

                        and THIS.ProcedureName = @m_ProcedureName

 

                        --if the sp doesn't have dependencies

                        --or if it has only dependencies already compiled

                        --it's ready to be compiled (here compilation is equivalent to assignment of sortOrder)

                        if @m_dependencies = 0

                                    begin

                                                update StoredProcs set SortOrder = (select max(SortOrder)+1 from StoredProcs)

                                                where ProcedureName = @m_ProcedureName

                                    end

                        --if it's not ready to compile, increase nbRuns to be processed later (after all the rest)

                        else

                                    begin

                                                update StoredProcs set NbRuns = NbRuns + 1

                                                where ProcedureName = @m_ProcedureName

                                    end

 

                        --find next proc not ordered yet

                        select top 1 @m_ProcedureName = ProcedureName from StoredProcs

                        where SortOrder = 0

                        order by NbRuns, ProcedureName

            end

 

set nocount off

 

-----------------------------------------------

--return ordered list of sp & fc

-----------------------------------------------

select distinct ProcedureName, SortOrder, Type--,ProcedureId,  ProcedureCode 

from StoredProcs

order by SortOrder

 

   

-----------------------------------------------

--if you want to clean the db...

-----------------------------------------------

--DROP table StoredProcs

 

-----------------------------------------------

-- StripSQLComments

-----------------------------------------------

-------------
 

create function dbo.StripSQLComments (@SOURCE_CODE varchar(4000))

returns varchar(4000)

as

begin

            declare @START int

            declare @END int

            declare @CLEAN_SOURCE_CODE varchar(4000)

            declare @TEMP_SOURCE_CODE varchar(4000)

            declare @FIRST_RUN bit

            

 

            --removing comment blocks (/* */)--------------------

            set @START = 1

            set @END = 1

            set @CLEAN_SOURCE_CODE = ''

            set @TEMP_SOURCE_CODE = @SOURCE_CODE

            set @FIRST_RUN = 1

 

            while (@END > 0 and @START > 0)

            begin

                        if @FIRST_RUN = 0

                                    begin

                                                select @TEMP_SOURCE_CODE = substring(@TEMP_SOURCE_CODE,@START+2,len(@TEMP_SOURCE_CODE)-@START+1+2)

                                    end

                        select @END = PATINDEX ( '%/*%' ,@TEMP_SOURCE_CODE)

                        if @END = 0

                                    begin

                                                select @CLEAN_SOURCE_CODE = @CLEAN_SOURCE_CODE + 

                                                            substring(@TEMP_SOURCE_CODE,1,len(@TEMP_SOURCE_CODE))

                                    end

                        else

                                    begin

                                                if @END > 1

                                                            begin

                                                                        select @CLEAN_SOURCE_CODE = @CLEAN_SOURCE_CODE + 

                                                                                    substring(@TEMP_SOURCE_CODE,1,@END-1)

                                                            end

                                                select @TEMP_SOURCE_CODE = substring(@TEMP_SOURCE_CODE,@END+2,len(@TEMP_SOURCE_CODE)-(@END+2)+1)

                                                select @START = PATINDEX ( '%*/%' ,@TEMP_SOURCE_CODE )

                                    end

                        set @FIRST_RUN = 0

 

            end

 

            --removing comment lines (-- )--------------------

            set @START = 1

            set @END = 1

            set @TEMP_SOURCE_CODE = @CLEAN_SOURCE_CODE

            set @CLEAN_SOURCE_CODE = ''

            set @FIRST_RUN = 1

 

 

            while (@END > 0 and @START > 0)

            begin

                        if @FIRST_RUN = 0

                                    begin

                                                select @TEMP_SOURCE_CODE = substring(@TEMP_SOURCE_CODE,@START+1,len(@TEMP_SOURCE_CODE)-@START+1+1)

                                    end

                        select @END = PATINDEX ( '%--%' ,@TEMP_SOURCE_CODE)

                        if @END = 0

                                    begin

                                                select @CLEAN_SOURCE_CODE = @CLEAN_SOURCE_CODE + 

                                                            substring(@TEMP_SOURCE_CODE,1,len(@TEMP_SOURCE_CODE))

                                    end

                        else

                                    begin

                                                if @END > 1

                                                            begin

                                                                        select @CLEAN_SOURCE_CODE = @CLEAN_SOURCE_CODE + 

                                                                                    substring(@TEMP_SOURCE_CODE,1,@END-1)

                                                            end

                                                select @TEMP_SOURCE_CODE = substring(@TEMP_SOURCE_CODE,@END+2,len(@TEMP_SOURCE_CODE)-(@END+2)+1)

                                                select @START = PATINDEX ( '%'+char(13)+'%' ,@TEMP_SOURCE_CODE )

                                    end

                        set @FIRST_RUN = 0

            end

 

            return @CLEAN_SOURCE_CODE

end
 







 


  