DECLARE @constraints CURSOR;
 DECLARE
         @table_full_name		nvarchar(max)
 ,       @constraint_name		nvarchar(max)
 ,       @constraint_full_name	nvarchar(max)
 ,       @constraint_definition	nvarchar(max)
 ;

 SET @constraints = CURSOR FOR
 SELECT
         QUOTENAME(cc.CONSTRAINT_SCHEMA) + '.' + QUOTENAME(cc.CONSTRAINT_NAME+'_STAGING') 	AS constraint_full_name
 ,       QUOTENAME(cc.CONSTRAINT_NAME+'_STAGING')                                      	AS constraint_name
 ,       QUOTENAME(ctu.TABLE_SCHEMA) + '.' + QUOTENAME(ctu.TABLE_NAME+'_STAGING')        	AS table_full_name
 ,       cc.CHECK_CLAUSE                                                      	AS constraint_definition
 FROM
 		INFORMATION_SCHEMA.CHECK_CONSTRAINTS cc
 		INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE ctu
 			ON ctu.CONSTRAINT_NAME = cc.CONSTRAINT_NAME
WHERE ctu.TABLE_NAME = 'BMS_PRO_GANTRY_TX'
 ORDER BY
         cc.CONSTRAINT_SCHEMA
 ,       cc.CONSTRAINT_NAME

 OPEN @constraints
 FETCH NEXT FROM @constraints INTO
 		@constraint_full_name,
		@constraint_name,
		@table_full_name,
		@constraint_definition;

 WHILE @@FETCH_STATUS = 0 BEGIN
         PRINT   ' '
         PRINT   'IF EXISTS (SELECT * FROM sys.check_constraints '
         PRINT   '                       WHERE object_id       = OBJECT_ID(N' + 
                                         CHAR(39) + @constraint_full_name + CHAR(39) + ')'
         PRINT   '                       AND parent_object_id  = OBJECT_ID(N' + 
                                         CHAR(39) + @table_full_name  + CHAR(39) + ')) '
         PRINT   '       ALTER TABLE ' + @table_full_name + ' DROP CONSTRAINT ' + 
                                        @constraint_name
         PRINT   'GO'
         PRINT   ' '
         PRINT   'ALTER TABLE '		+ @table_full_name + ' WITH CHECK '
         PRINT   '       ADD CONSTRAINT '	+ @constraint_name
         PRINT   '       CHECK '		+ @constraint_definition
         PRINT   'GO'
         PRINT   ' '
         PRINT   'ALTER TABLE ' + @table_full_name + ' CHECK CONSTRAINT ' + 
					@constraint_name
         PRINT   'GO'
         PRINT   ' '
         FETCH NEXT FROM @constraints INTO
         			@constraint_full_name,
				@constraint_name,
				@table_full_name,
				@constraint_definition;
 END
 CLOSE           	@constraints;
 DEALLOCATE      	@constraints;


---------------------------------------------------
alter table MyOtherTable nocheck constraint all
delete from MyTable
alter table MyOtherTable check constraint all

---------------------------------

SELECT 'ALTER TABLE DBO.'+NAME+' nocheck constraint all','ALTER TABLE DBO.'+NAME+' check constraint all'
FROM 		SYS.TABLES
WHERE NAME LIKE 'BMS%'

---db level
EXEC sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'