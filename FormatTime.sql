
SELECT 	right('0' + rtrim(convert(char(2), DATEDIFF(SECOND,START_TIME,END_TIME) / (60 * 60))), 2) + ':' + 
	right('0' + rtrim(convert(char(2), (DATEDIFF(SECOND,START_TIME,END_TIME) / 60) % 60)), 2) + ':' + 
	right('0' + rtrim(convert(char(2), DATEDIFF(SECOND,START_TIME,END_TIME) % 60)),2)
,* FROM ETLMD.DBO.XFLOWSTATUS
ORDER BY 1