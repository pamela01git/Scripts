/*1新增欄位*/

USE PCUSEGDB
GO
/* y:重建PK  N:不重建PK*/
ALTER TABLE odsdba.FS_BrPdClAcPf_MA  ADD DeptNo  Char(3) NOT NULL DEFAULT -1;   --OK y --
--ALTER TABLE odsdba.FS_BrPdCuCnt_MA  ADD DeptNo  Char(3) NOT NULL DEFAULT -1;    --OK y --
ALTER TABLE odsdba.FS_BrPdDelq_MA  ADD DeptNo  Char(3) NOT NULL DEFAULT -1;     --OK y --
ALTER TABLE odsdba.FS_BrPdNwAcPf_MA  ADD DeptNo  Char(3) NOT NULL DEFAULT -1;   --OK y --
ALTER TABLE odsdba.FS_BrPdPf_MA  ADD DeptNo  Char(3) NOT NULL DEFAULT -1;       --OK y --
--ALTER TABLE odsdba.FS_CampPdDelq_MA  ADD DeptNo  Char(3);   --OK y
--ALTER TABLE odsdba.FS_LnPdLive_MA  ADD DeptNo  Char(3);     --OK n
--ALTER TABLE odsdba.FS_PCuBrCampPdPf_MW  ADD DeptNo  Char(3) --OK y
--ALTER TABLE odsdba.FS_PCuBrPdCrSel_MA  ADD DeptNo  Char(3); --OK n
ALTER TABLE odsdba.FS_PCuBrPdCtb_MA  ADD DeptNo  Char(3) NOT NULL DEFAULT -1;   --OK n --
ALTER TABLE odsdba.FS_PCuBrPdDelq_MA ADD DeptNo  Char(3) NOT NULL DEFAULT -1;   --OK n --
ALTER TABLE odsdba.FS_PCuBrPdDelq_MS ADD DeptNo  Char(3) NOT NULL DEFAULT -1;   --OK y --
ALTER TABLE odsdba.FS_PCuBrPdDelq_MW ADD DeptNo  Char(3) NOT NULL DEFAULT -1;   --OK y --
ALTER TABLE odsdba.FS_PCuBrPdGrDe_MA ADD DeptNo  Char(3) NOT NULL DEFAULT -1;   --OK n --
ALTER TABLE odsdba.FS_PCuBrPdPf_MA ADD DeptNo  Char(3) NOT NULL DEFAULT -1;     --OK n --
ALTER TABLE odsdba.FS_PCuBrPdPf_MS ADD DeptNo  Char(3) NOT NULL DEFAULT -1;     --OK y --
ALTER TABLE odsdba.FS_PCuBrPdPf_MW ADD DeptNo  Char(3) NOT NULL DEFAULT -1;     --OK y --
ALTER TABLE odsdba.FS_PdIntrtPf_MA ADD DeptNo  Char(3) NOT NULL DEFAULT -1;     --OK y --
ALTER TABLE odsdba.FS_PdPf_MA ADD DeptNo  Char(3) NOT NULL DEFAULT -1;          --OK y --

/*2修改鍵值*/
--1.FS_BrPdClAcPf_MA(轉PARTITION)
UPDATE odsdba.FS_BrPdClAcPf_MA
SET DeptNo='-1'
GO
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[odsdba].[FS_BrPdClAcPf_MA]') AND name = N'PK_FS_BrPdClAcPf_MA')
ALTER TABLE [odsdba].[FS_BrPdClAcPf_MA] DROP CONSTRAINT [PK_FS_BrPdClAcPf_MA]
GO
ALTER TABLE odsdba.FS_BrPdClAcPf_MA ADD CONSTRAINT
	PK_FS_BrPdClAcPf_MA PRIMARY KEY CLUSTERED 
	(
	DATADT,
	GLORGNO,
	PDBCCD,
	INTRANKCD,
	PRDRANKCD,
	DeptNo
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON PCuSegDB_PS_FS(DATADT)
GO



--2.FS_BrPdCuCnt_MA(轉PARTITION)


--3.FS_BrPdDelq_MA(轉PARTITION)
UPDATE odsdba.FS_BrPdDelq_MA
SET DeptNo='-1'
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[odsdba].[FS_BrPdDelq_MA]') AND name = N'PK_FS_BrPdDelq_MA')
ALTER TABLE [odsdba].[FS_BrPdDelq_MA] DROP CONSTRAINT [PK_FS_BrPdDelq_MA]
GO
ALTER TABLE odsdba.FS_BrPdDelq_MA ADD CONSTRAINT
	PK_FS_BrPdDelq_MA PRIMARY KEY CLUSTERED 
	(
	DATADT, 
	GLORGNO, 
	PDBCCD,
	DeptNo
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON PCuSegDB_PS_FS(DATADT)

GO

--4.FS_BrPdNwAcPf_MA(轉PARTITION)
UPDATE odsdba.FS_BrPdNwAcPf_MA
SET DeptNo='-1'
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[odsdba].[FS_BrPdNwAcPf_MA]') AND name = N'PK_FS_BrPdNwAcPf_MA')
ALTER TABLE [odsdba].[FS_BrPdNwAcPf_MA] DROP CONSTRAINT [PK_FS_BrPdNwAcPf_MA]
GO
ALTER TABLE odsdba.FS_BrPdNwAcPf_MA ADD CONSTRAINT
	PK_FS_BrPdNwAcPf_MA PRIMARY KEY CLUSTERED 
	(
	DATADT, 
	GLORGNO, 
	PDBCCD, 
	INTRANKCD,
	DeptNo
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON PCuSegDB_PS_FS(DATADT)

GO

--5.FS_BrPdPf_MA(轉PARTITION)
UPDATE odsdba.FS_BrPdPf_MA
SET DeptNo='-1'
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[odsdba].[FS_BrPdPf_MA]') AND name = N'PK_FS_BrPdPf_MA')
ALTER TABLE [odsdba].[FS_BrPdPf_MA] DROP CONSTRAINT [PK_FS_BrPdPf_MA]
GO
ALTER TABLE odsdba.FS_BrPdPf_MA ADD CONSTRAINT
	PK_FS_BrPdPf_MA PRIMARY KEY CLUSTERED 
	(
	DATADT,
	GLORGNO,
	PDBCCD,
	DeptNo
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON PCuSegDB_PS_FS(DATADT)

GO

--9.FS_PCuBrPdCrSel_MA(主鍵為DATADT, PDBCCAMPCBNCD, LstRecNo，故不重建PK)

--10.FS_PCuBrPdCtb_MA(主鍵為DATADT, LstRecNo，故不重建PK)

--11.FS_PCuBrPdDelq_MA(主鍵為DATADT, LstRecNo，故不重建PK)

--12.FS_PCuBrPdDelq_MS(轉PARTITION)
UPDATE odsdba.FS_PCuBrPdDelq_MS
SET DeptNo='-1'
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[odsdba].[FS_PCuBrPdDelq_MS]') AND name = N'PK_FS_PCuBrPdDelq_MS')
ALTER TABLE [odsdba].[FS_PCuBrPdDelq_MS] DROP CONSTRAINT [PK_FS_PCuBrPdDelq_MS]
GO
ALTER TABLE odsdba.FS_PCuBrPdDelq_MS ADD CONSTRAINT
	PK_FS_PCuBrPdDelq_MS PRIMARY KEY CLUSTERED 
	(
	DATADT, 
	CUSTKEY, 
	GLORGNO, 
	PDBCCD,
	DeptNo
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON PCuSegDB_PS_FS(DATADT)

GO

--13.FS_PCuBrPdDelq_MW(無轉PARTITION)

UPDATE odsdba.FS_PCuBrPdDelq_MW
SET DeptNo='-1'
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[odsdba].[FS_PCuBrPdDelq_MW]') AND name = N'PK_FS_PCuBrPdDelq_MW')
ALTER TABLE [odsdba].[FS_PCuBrPdDelq_MW] DROP CONSTRAINT [PK_FS_PCuBrPdDelq_MW]
GO
ALTER TABLE odsdba.FS_PCuBrPdDelq_MW ADD CONSTRAINT
	PK_FS_PCuBrPdDelq_MW PRIMARY KEY CLUSTERED 
	(
	CUSTKEY, 
	GLORGNO, 
	PDBCCD,
	DeptNo
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

--14.FS_PCuBrPdGrDe_MA(主鍵為DATADT, LstRecNo，故不重建PK)


--15.FS_PCuBrPdPf_MA(主鍵為DATADT, LstRecNo，故不重建PK)

--16.FS_PCuBrPdPf_MS(轉PARTITION)

UPDATE odsdba.FS_PCuBrPdPf_MS
SET DeptNo='-1'
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[odsdba].[FS_PCuBrPdPf_MS]') AND name = N'PK_FS_PCuBrPdPf_MS')
ALTER TABLE [odsdba].[FS_PCuBrPdPf_MS] DROP CONSTRAINT [PK_FS_PCuBrPdPf_MS]
GO
ALTER TABLE odsdba.FS_PCuBrPdPf_MS ADD CONSTRAINT
	PK_FS_PCuBrPdPf_MS PRIMARY KEY CLUSTERED 
	(
	DATADT, 
	CUSTKEY, 
	GLORGNO, 
	PDBCCD,
	DeptNo
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON PCuSegDB_PS_FS(DATADT)

GO

--17.FS_PCuBrPdPf_MW(無轉PARTITION)

UPDATE odsdba.FS_PCuBrPdPf_MW
SET DeptNo='-1'
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[odsdba].[FS_PCuBrPdPf_MW]') AND name = N'PK_FS_PCuBrPdPf_MW')
ALTER TABLE [odsdba].[FS_PCuBrPdPf_MW] DROP CONSTRAINT [PK_FS_PCuBrPdPf_MW]
GO
ALTER TABLE odsdba.FS_PCuBrPdPf_MW ADD CONSTRAINT
	PK_FS_PCuBrPdPf_MW PRIMARY KEY CLUSTERED 
	(
	CUSTKEY, 
	GLORGNO, 
	PDBCCD,
	DeptNo
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

--18.FS_PdIntrtPf_MA(轉PARTITION)

UPDATE odsdba.FS_PdIntrtPf_MA
SET DeptNo='-1'
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[odsdba].[FS_PdIntrtPf_MA]') AND name = N'PK_FS_PdIntrtPf_MA')
ALTER TABLE [odsdba].[FS_PdIntrtPf_MA] DROP CONSTRAINT [PK_FS_PdIntrtPf_MA]
GO
ALTER TABLE odsdba.FS_PdIntrtPf_MA ADD CONSTRAINT
	PK_FS_PdIntrtPf_MA PRIMARY KEY CLUSTERED 
	(
	DATADT, 
	PDBCCD, 
	INTRANKCD, 
	TYPECD,
	DeptNo
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON PCuSegDB_PS_FS(DATADT)

GO

--19.FS_PdPf_MA(轉PARTITION)

UPDATE odsdba.FS_PdPf_MA
SET DeptNo='-1'
GO
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[odsdba].[FS_PdPf_MA]') AND name = N'PK_FS_PdPf_MA')
ALTER TABLE [odsdba].[FS_PdPf_MA] DROP CONSTRAINT [PK_FS_PdPf_MA]
GO
ALTER TABLE odsdba.FS_PdPf_MA ADD CONSTRAINT
	PK_FS_PdPf_MA PRIMARY KEY CLUSTERED 
	(
	DATADT, 
	PDBCCD,
	DeptNo
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON PCuSegDB_PS_FS(DATADT)

GO
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          



