MSSQL預設的定序=Chinese_Taiwan_Stroke_CI_AS，CI:Case Insensitive，AS:Accent sensitive


--DROP TABLE ##TBL
CREATE TABLE ##TBL (COL_1 CHAR(10) PRIMARY KEY, COL_2 CHAR(10))

ALTER TABLE ##TBL ALTER COLUMN COL_2 CHAR(10) COLLATE SQL_Latin1_General_CP1_CS_AS

INSERT INTO ##TBL 
SELECT 'A','a'

select * from  ##TBL 
where COL_2= 'a'
