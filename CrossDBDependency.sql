if object_id('hisdb..SPDependency') is not null drop table SPDependency
create table SPDependency
            (ServidorReferente sysname,
            DB_Referente sysname,
            SchemaReferente sysname,
            ObjetoReferente sysname,
            TipoObjetoReferente sysname,
            ServidorReferenciado sysname,
            DatabaseReferenciado sysname,
            SchemaReferenciado sysname,
            ObjetoReferenciado sysname,
            TipoObjetoReferenciado sysname,
            DtaConsulta datetime)

DECLARE @command VARCHAR(5000)
   SET @command = 'Use [' + '?' + '] ;' + CHAR(10) + CHAR(13);
   SET @command += 'IF db_name() NOT in (''master'', ''msdb'', ''tempdb'', ''model'', ''distribution'', ''distribution1'', ''ReportServer'', ''ReportServerTempDB'' )
      SELECT @@SERVERNAME AS ServidorReferente, 
      DB_NAME() AS DB_Referente,
      OBJECT_SCHEMA_NAME(depz.referencing_id) As SchemaReferente,
      OBJECT_NAME(depz.referencing_id) As ObjetoReferente, 
      objz.type_desc as TipoObjetoReferente, 
      ISNULL(referenced_server_name, @@SERVERNAME) as ServidorReferenciado,
      ISNULL(referenced_database_name, DB_NAME()) as DatabaseReferenciado,
      ISNULL(referenced_schema_name,    OBJECT_SCHEMA_NAME(depz.referencing_id)) as SchemaReferenciado, 
      referenced_entity_name as ObjetoReferenciado,
      ISNULL(obj2.type_desc, ''(n/d)'') as TipoObjetoReferenciado,
      CURRENT_TIMESTAMP AS DtaConsulta
   FROM sys.sql_expression_dependencies depz
      INNER JOIN sys.objects objz on depz.referencing_id = objz.object_id
      LEFT OUTER JOIN sys.objects obj2 on obj2.object_id = depz.referenced_id 
   WHERE referencing_minor_id = 0 ' --I don't want to retrieve computed columns

   TRUNCATE TABLE SPDependency
   INSERT INTO SPDependency
            (ServidorReferente
            ,DB_Referente
            ,SchemaReferente
            ,ObjetoReferente
            ,TipoObjetoReferente
            ,ServidorReferenciado
            ,DatabaseReferenciado
            ,SchemaReferenciado
            ,ObjetoReferenciado
            ,TipoObjetoReferenciado
            ,DtaConsulta)
   EXEC sp_MSForEachDB @command


   SELECT REF_DB_NAME,COUNT(DISTINCT REF_TABLE_NAME)
   FROM (
   select upper(DatabaseReferenciado) AS REF_DB_NAME,ObjetoReferenciado AS REF_TABLE_NAME,count(1) AS CNT from SPDependency
   where DB_Referente= 'hisdb'
    and DatabaseReferenciado <> 'HISDB'
	and DatabaseReferenciado like 'p%'
	group by  upper(DatabaseReferenciado),ObjetoReferenciado
	) A
	GROUP BY REF_DB_NAME
	ORDER BY 1