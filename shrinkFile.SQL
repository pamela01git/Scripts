select CAST(FILEPROPERTY(name, 'SpaceUsed') AS int),*
FROM sys.database_files;