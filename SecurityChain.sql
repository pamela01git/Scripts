/*
Demo of Security Chain
*/

-- Login by Administrator
USE tempdb
GO

-- Create a schema
CREATE SCHEMA odsdba
GO

-- Create a user with minimal privilege
CREATE LOGIN normaluser WITH PASSWORD = 'ab12345', DEFAULT_DATABASE = tempdb
GO
CREATE USER normaluser WITH DEFAULT_SCHEMA = odsdba
GO



/*** Open a new query window and logon with "normaluser" ***/

-- then try to create a simple table ( it must be fail with no privilege )
CREATE TABLE odsdba.table1
( f1 VARCHAR(10) )
GO



/*** Change back to Administrator ***/

-- Create a procedure for "normaluser" to do the CREATE DDL
CREATE PROCEDURE odsdba.p_CreateTable 
@schemaname VARCHAR(80), @tablename VARCHAR(80)
WITH EXEC AS OWNER		-- or 'sa'
AS
DECLARE @sqlstatement VARCHAR(MAX)
SET @sqlstatement =
' IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.TABLES
             WHERE TABLE_SCHEMA = ''' + @schemaname + '''
               AND TABLE_NAME = ''' + @tablename + ''' ) 
     DROP TABLE ' + @schemaname + '.' + @tablename + '
;
  CREATE TABLE ' + @schemaname + '.' + @tablename + '
  ( f1 VARCHAR(10) )
;
  GRANT SELECT ON ' + @schemaname + '.' + @tablename + ' TO normaluser
'
EXECUTE ( @sqlstatement )
GO

GRANT EXECUTE ON odsdba.p_CreateTable TO normaluser
GO



/*** Switch to "normaluser" ***/

EXEC odsdba.p_CreateTable 'odsdba', 'table1'
GO
SELECT * FROM odsdba.table1
GO
-- try to Create table again ...
CREATE TABLE odsdba.table2
( f1 VARCHAR(10) )
GO    -- it fail again

/*
You dont have privilege to CREATE PROCEDURE ... WITH EXEC AS 'sa' by "normaluser"
test...
1. (dbo)
GRANT CREATE PROCEDURE TO normaluser
GO
GRANT CONTROL ON SCHEMA::odsdba TO normaluser
GO
2. (normaluser)
CREATE PROCEDURE odsdba.p1 as SELECT 'testing...'
GO	--> done!
CREATE PROCEDURE odsdba.p2 WITH EXEC AS 'sa' AS SELECT 'testing...'
GO	--> fail! no privilege
*/



/*** Change back to Administrator ***/

-- Clearup
USE tempdb
DROP PROCEDURE odsdba.p_CreateTable
GO
DROP USER normaluser
GO
DROP LOGIN normaluser
GO
-- DROP TABLE(s), PROCEDURE(s) you have created.
-- and GO
DROP SCHEMA odsdba
GO
