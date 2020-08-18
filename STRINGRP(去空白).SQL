CREATE     FUNCTION DBO.[STRINGRP] (
    @Input varchar(8000)
    ) RETURNS VARCHAR(8000)
AS  
BEGIN 
    --西元年月日(文字) 轉 datetime
    --可接受 yyyymmdd, yyyy/mm/dd
    
    WHILE CHARINDEX('  ',@Input)>0
      BEGIN
        SELECT @Input=REPLACE(@Input,'  ',' ')
      END
    RETURN @Input ;
END
GO