
cREATE MASTER KEY ENCRYPTION BY PASSWORD = 'P@ssw0rd'

--drop database scoped credential george
CREATE DATABASE SCOPED CREDENTIAL mlaccount  WITH IDENTITY = 'mlaccount',  
SECRET = 'pass@word1';

--drop external data source pegatron
CREATE EXTERNAL DATA SOURCE  [SIGMUECSitecore_Analytics]
WITH 
( 
    TYPE=rdbms,
    LOCATION='sigmuecsql.database.windows.net', 
    DATABASE_NAME='SIGMUECSitecore_Analytics', 
    CREDENTIAL= mlaccount, 
   -- SHARD_MAP_NAME='ShardMap' 
);

--drop external table dbo.dim_date
CREATE EXTERNAL TABLE [dbo].[Fact_PageViews]( 
	[Date] [smalldatetime] NOT NULL,
	[ItemId] [uniqueidentifier] NOT NULL,
	[ContactId] [uniqueidentifier] NOT NULL,
	[Views] [bigint] NOT NULL,
	[Duration] [bigint] NOT NULL,
	[Visits] [bigint] NOT NULL,
	[Value] [bigint] NOT NULL,
	[TestId] [uniqueidentifier] NULL,
	[TestCombination] [binary](16) NULL,
	)
WITH 
( 
    DATA_SOURCE = SIGMUECSitecore_Analytics
);