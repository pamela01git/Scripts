CREATE FUNCTION [dbo].[fn_IntCSVSplit]
( @RowData NVARCHAR(MAX) )
RETURNS @RtnValue TABLE 
( Data INT ) 
AS
BEGIN 
    DECLARE @Iterator INT
    DECLARE @WorkString NVARCHAR(MAX)
    SET @Iterator = 1
    DECLARE @FoundIndex INT
    SET @FoundIndex = CHARINDEX(',',@RowData)
    WHILE (@FoundIndex>0)
    BEGIN
  SET @WorkString = LTRIM(RTRIM(SUBSTRING(@RowData, 1, @FoundIndex - 1)))
  IF ISNUMERIC(@WorkString) = 1
  BEGIN
   INSERT INTO @RtnValue (data) VALUES (@WorkString)
  END
  ELSE
  BEGIN
   INSERT INTO @RtnValue (data) VALUES(NULL)
  END
        SET @RowData = SUBSTRING(@RowData, @FoundIndex + 1,LEN(@RowData))
        SET @Iterator = @Iterator + 1
        SET @FoundIndex = CHARINDEX(',', @RowData)
    END
    IF ISNUMERIC(LTRIM(RTRIM(@RowData))) = 1
    BEGIN
        INSERT INTO @RtnValue (Data) SELECT LTRIM(RTRIM(@RowData))
    END
    RETURN
END
 
go
