How to determine which version of SQL Server 2005 is running
To determine which version of Microsoft SQL Server 2005 is running, connect to SQL Server 2005 by using SQL Server Management Studio, and then run the following Transact-SQL statement:SELECT  SERVERPROPERTY('productversion'), SERVERPROPERTY ('productlevel'), SERVERPROPERTY ('edition')
SELECT  SERVERPROPERTY('productversion'), SERVERPROPERTY ('productlevel'), SERVERPROPERTY ('edition')

SELECT SERVERPROPERTY('ServerName') AS ServerName
SELECT SERVERPROPERTY('BuildClrVersion') AS BuildClrVersion
SELECT SERVERPROPERTY('Collation') AS Collation
SELECT SERVERPROPERTY('CollationID') AS CollationID
SELECT SERVERPROPERTY('ComparisonStyle') AS ComparisonStyle
SELECT SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS ComputerNamePhysicalNetBIOS
SELECT SERVERPROPERTY('Edition') AS Edition
SELECT SERVERPROPERTY('EditionID') AS EditionID
SELECT SERVERPROPERTY('EngineEdition') AS EngineEdition
SELECT SERVERPROPERTY('InstanceName') AS InstanceName
SELECT SERVERPROPERTY('IsClustered') AS IsClustered
SELECT SERVERPROPERTY('IsFullTextInstalled') AS IsFullTextInstalled
SELECT SERVERPROPERTY('IsIntegratedSecurityOnly') AS IsIntegratedSecurityOnly
SELECT SERVERPROPERTY('IsSingleUser') AS IsSingleUser
SELECT SERVERPROPERTY('LCID') AS LCID
SELECT SERVERPROPERTY('LicenseType') AS LicenseType
SELECT SERVERPROPERTY('MachineName') AS MachineName
SELECT SERVERPROPERTY('NumLicenses') AS NumLicenses
SELECT SERVERPROPERTY('ProcessID') AS ProcessID
SELECT SERVERPROPERTY('ProductVersion') AS ProductVersion
SELECT SERVERPROPERTY('ProductLevel') AS ProductLevel
SELECT SERVERPROPERTY('ResourceLastUpdateDateTime') AS ResourceLastUpdateDateTime
SELECT SERVERPROPERTY('SqlCharSet') AS SqlCharSet
SELECT SERVERPROPERTY('SqlCharSetName') AS SqlCharSetName
SELECT SERVERPROPERTY('SqlSortOrder') AS SqlSortOrder
SELECT SERVERPROPERTY('SqlSortOrderName') AS SqlSortOrderName

SELECT SERVERPROPERTY('Collation') AS Collation


SELECT DATABASEPROPERTYEX('SiebelDB','COLLATION')