declare  @cmd nvarchar(max)
--select @cmd=text from syscomments 
--where id = (select id from sysobjects where xtype='tr' and name = 'after_insert_trigger')

SELECT * FROM SYS.OBJECTS S1
WHERE TYPE= 'TR' 
  AND PARENT_OBJECT_ID= (OBJECT_ID(N'ExecutionLog'))

SELECT @cmd=OBJECT_DEFINITION (OBJECT_ID(N'after_insert_trigger')) 
print @cmd 