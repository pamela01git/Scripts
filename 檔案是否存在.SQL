DECLARE @IsFileExists INT
DECLARE @FileName varchar(255);
DECLARE @TableName varchar(100);
SET @TableName = 'OPRMOperatingRoom'; -- Set table name
SET @FileName = 'dir "C:\SqlBulk\SeedData\Operation\'+@TableName+'.bcp" /B'; -- set bcp file 
EXEC @IsFileExists = XP_CMDSHELL @filename, NO_OUTPUT


IF @IsFileExists = 1 
  PRINT 'File Donot exists'
ELSE
PRINT 'File exists'