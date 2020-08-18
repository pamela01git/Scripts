DECLARE @kk nvarchar(300)
DECLARE @hdoc int
        
BEGIN

	SET @kk = (SELECT '<?xml version="1.0" encoding="utf-16"?>' +
	'<string>20070701</string>')
		
	EXEC sp_xml_preparedocument @hdoc OUTPUT, @kk

	SELECT * FROM OPENXML(@hdoc ,'/',2)
	WITH (string varchar(10))
	exec sp_xml_removedocument @hdoc

end