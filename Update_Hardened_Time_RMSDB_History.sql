USE [MSCollect]
GO
/****** Object:  StoredProcedure [dbo].[Update_Hardened_Time_RMSDB_History]    Script Date: 2016/3/4 ¤W¤È 09:22:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	-BRIAN. 2014.0213w4
		-copy from rdl
Execute Sample:
	EXEC MSCollect.dbo.Update_Hardened_Time_RMSDB_History
test:
	select * from dbo.Hardened_Time_RMSDB_History
*/
ALTER PROCEDURE [dbo].[Update_Hardened_Time_RMSDB_History]
AS
SET NOCOUNT ON
IF EXISTS(SELECT 1 FROM master.sys.dm_hadr_availability_group_states WHERE primary_replica = @@SERVERNAME)
BEGIN
	DECLARE @collect_datetime datetime = getdate()
		-- drop table dbo.Hardened_Time_RMSDB_History
	IF OBJECT_ID('dbo.Hardened_Time_RMSDB_History') IS NULL
		CREATE TABLE [dbo].[Hardened_Time_RMSDB_History](
			[collect_datetime] [datetime] NOT NULL,
			[Servername] [nvarchar](128) NULL,
			[AGName] [sysname] NULL,
			[database_name] [nvarchar](128) NULL,
			[last_commit_time_1] [datetime] NULL,
			[last_sent_time_2] [datetime] NULL,
			[last_received_time_4] [datetime] NULL,
			[last_hardened_time_5] [datetime] NULL,
			[last_redone_time_6] [datetime] NULL,
			[RTO] [bigint] NULL,
			[RPO] [bigint] NULL,
			[NowTime] [datetime] NOT NULL,
			[Delayvsharden] [int] NULL,
			[DelayvsNow] [int] NULL,
			[last_hardened_lsn] [varchar](41) NULL,
			[last_redone_lsn] [varchar](41) NULL,
			[lsndiff] [numeric](33, 7) NULL
		) ON [PRIMARY]

	INSERT INTO dbo.Hardened_Time_RMSDB_History
	SELECT @collect_datetime 'collect_datetime', @@SERVERNAME Servername,a.name AGName,c.database_name,last_commit_time as [last_commit_time_1],
		last_sent_time as [last_sent_time_2],
		last_received_time as [last_received_time_4],
		last_hardened_time as [last_hardened_time_5],
		last_redone_time as [last_redone_time_6],
		(case when redo_rate > 0 then redo_queue_size / redo_rate else 0 end )as [RTO],
		(case when log_send_rate > 0 then log_send_queue_size / log_send_rate else 0 end )as [RPO],
		getdate()  [NowTime],
		DATEDIFF(SS,last_commit_time,last_hardened_time) as [Delayvsharden],
		DATEDIFF(SS,getdate(),last_hardened_time) as [DelayvsNow],
		LEFT(last_hardened_lsn,len(last_hardened_lsn)-5)last_hardened_lsn,
		LEFT(last_redone_lsn,len(last_redone_lsn)-5)last_redone_lsn,
		last_hardened_lsn/100000-last_redone_lsn/100000 as lsndiff
		FROM master.sys.availability_groups a
			JOIN master.sys.dm_hadr_database_replica_states e on e.group_id=a.group_id  AND is_local =0 
			JOIN master.sys.dm_hadr_database_replica_cluster_states c on c.replica_id = e.replica_id AND c.group_database_id=e.group_database_id
		WHERE database_name = 'BMSDB'

	DELETE FROM dbo.Hardened_Time_RMSDB_History
		WHERE collect_datetime < DATEADD(MONTH,-3, @collect_datetime)
END
