USE master EXEC sp_dboption 'dbname', 'autoshrink', 'FALSE' 

SELECT DATABASEPROPERTYEX ('FjuDB', 'Isautoshrink')