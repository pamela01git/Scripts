--WITH (TABLOCKX)

use dmfin
go
select * from sys.tables
where lock_escalation_desc='DISABLE'
order by name

ALTER TABLE [dbo].[FS_CC_WCP] SET (LOCK_ESCALATION = DISABLE)
GO

ALTER TABLE [dbo].[FS_CC_KPI_AR_STAGE_CC] SET (LOCK_ESCALATION = TABLE)