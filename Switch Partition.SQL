--create non_partition table (FS_LnPdLive_MA2)

CREATE TABLE [odsdba].[FS_LnPdLive_MA2](
	[DATADT] [datetime] NOT NULL,
	[YRDT] [datetime] NULL,
	[PDBCCD] [char](10) NULL,
	[TAGEGUP] [char](20) NULL,
	[TAGEGUPSEQ] [numeric](2, 0) NULL,
	[AGERANKCD] [numeric](3, 0) NULL,
	[SEX] [char](2) NULL,
	[CZIPCD] [numeric](5, 0) NULL,
	[ZIPCAT2NO] [numeric](4, 0) NULL,
	[ZIPCAT3] [char](10) NULL,
	[ZIPCAT3SEQ] [numeric](4, 0) NULL,
	[ACCTCNT] [numeric](9, 0) NULL,
	[BASEACCTCNT] [numeric](9, 0) NULL DEFAULT ((0)),
	[ACCTNEWCNT] [numeric](9, 0) NULL,
	[ACCTCLOSEDCNT] [numeric](9, 0) NULL,
	[ACCTCONTRIBUTIONAMT] [numeric](12, 0) NULL,
	[AVGLIVEMN] [numeric](7, 0) NULL,
	[DATACNT] [numeric](7, 0) NULL,
	[LSTRECNO] [numeric](8, 0) IDENTITY(1,1) NOT NULL,
	[ORGDATASRC] [char](16) NULL,
	[ORGDEDT] [datetime] NULL,
	[LSTCYCDT] [datetime] NULL,
	[LSTSYSDT] [datetime] NULL
)  on PCUSEGDB_FS_200701

ALTER TABLE [odsdba].[FS_LnPdLive_MA2] ADD  CONSTRAINT [PK_FS_LnPdLive_MA2] PRIMARY KEY CLUSTERED 
(
	[DATADT] ,
	[LSTRECNO]
)
go




--將partition table(odsdba.FS_LnPdLive_MA1)移到non-partition table(odsdba.FS_LnPdLive_MA2)
Alter table odsdba.FS_LnPdLive_MA1 Switch Partition 26 To odsdba.FS_LnPdLive_MA2;
Go
select datadt,count(1) from odsdba.FS_LnPdLive_MA1
group by datadt
select datadt,count(1) from odsdba.FS_LnPdLive_MA2
group by datadt
select * from  odsdba.FS_LnPdLive_MA1
select * from  odsdba.FS_LnPdLive_MA2

--增加non-partition table之partition function之constraint
Alter table odsdba.FS_LnPdLive_MA2 add constraint check_FS_LnPdLive_MA2 check  ( DATADT = '20070101')
--將non-partition table(odsdba.FS_LnPdLive_MA2)移到partition table(odsdba.FS_LnPdLive_MA1)
Alter table odsdba.FS_LnPdLive_MA2 Switch to odsdba.FS_LnPdLive_MA1 Partition 26
go
select datadt,count(1) from odsdba.FS_LnPdLive_MA1
group by datadt
select datadt,count(1) from odsdba.FS_LnPdLive_MA2
group by datadt
select * from  odsdba.FS_LnPdLive_MA1
select * from  odsdba.FS_LnPdLive_MA2