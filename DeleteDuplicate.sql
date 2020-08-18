select count(1) from [dbo].BMS_SET_WRITE_OFF_DA
delete s
from 
(select *,row_number() over(partition by 	
	[IMPORT_DATE] ,
	[CHANNEL_CD]  order by IMPORT_DATE) as rowno
from  [dbo].BMS_SET_WRITE_OFF_DA) s
where rowno > 1

/****** Object:  Index [PK_BMS_SET_TX_BATCH_OFFLINE_DA]    Script Date: 2013/4/29 ¤U¤È 05:32:24 ******/
/****** Object:  Index [PK_BMS_SET_WRITE_OFF_DA]    Script Date: 2013/4/29 ¤U¤È 05:32:55 ******/
ALTER TABLE [dbo].[BMS_SET_WRITE_OFF_DA] ADD  CONSTRAINT [PK_BMS_SET_WRITE_OFF_DA] PRIMARY KEY CLUSTERED 
(
	[IMPORT_DATE] ,
	[CHANNEL_CD] 
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, DATA_COMPRESSION = PAGE) ON [ReportDB_PS_DATE]([IMPORT_DATE])
GO


select count(1) from [dbo].BMS_SET_WRITE_OFF_DA



