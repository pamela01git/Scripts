
DECLARE @@GIVING_TIME DATETIME
SET @@GIVING_TIME = GETDATE()
PRINT @@GIVING_TIME

--Find Top Session
INSERT INTO [SESSIONS].dbo.TOPSESSION
SELECT 
CONN.client_net_address,
CONN.session_id,
CONN.connect_time,
PROCES.last_batch,
Datediff(mi,PROCES.last_batch,getdate()) AS DURATION,
CONN.last_read,
CONN.last_write,
CONN.most_recent_session_id,CONN.net_transport,
CONN.protocol_type,CONN.protocol_version,CONN.endpoint_id,CONN.encrypt_option,
CONN.auth_scheme,CONN.node_affinity,CONN.num_reads,
CONN.num_writes,CONN.net_packet_size,CONN.client_tcp_port,
CONN.local_net_address,CONN.local_tcp_port,CONN.connection_id,
CONN.parent_connection_id,CONN.most_recent_sql_handle,
--GETDATE() AS GIVING_TIME
@@GIVING_TIME
--INTO TOPSESSION
FROM sys.dm_exec_connections CONN
JOIN sys.sysprocesses PROCES 
ON CONN.session_id = PROCES.spid
GROUP BY 
CONN.client_net_address,
CONN.session_id,
CONN.connect_time,
PROCES.last_batch,
Datediff(mi,PROCES.last_batch,getdate()),
CONN.last_read,
CONN.last_write,
CONN.most_recent_session_id,CONN.net_transport,
CONN.protocol_type,CONN.protocol_version,CONN.endpoint_id,CONN.encrypt_option,
CONN.auth_scheme,CONN.node_affinity,CONN.num_reads,
CONN.num_writes,CONN.net_packet_size,CONN.client_tcp_port,
CONN.local_net_address,CONN.local_tcp_port,CONN.connection_id,
CONN.parent_connection_id,CONN.most_recent_sql_handle
ORDER BY Datediff(mi,PROCES.last_batch,getdate()) DESC


INSERT INTO [SESSIONS].dbo.IDLE_SESSION
SELECT 
CONN.client_net_address,
CONN.session_id,
CONN.connect_time,
PROCES.last_batch,
Datediff(mi,PROCES.last_batch,getdate()) AS DURATION,
CONN.last_read,
CONN.last_write,
CONN.most_recent_session_id,CONN.net_transport,
CONN.protocol_type,CONN.protocol_version,CONN.endpoint_id,CONN.encrypt_option,
CONN.auth_scheme,CONN.node_affinity,CONN.num_reads,
CONN.num_writes,CONN.net_packet_size,CONN.client_tcp_port,
CONN.local_net_address,CONN.local_tcp_port,CONN.connection_id,
CONN.parent_connection_id,CONN.most_recent_sql_handle,
--GETDATE() AS GIVING_TIME
@@GIVING_TIME
--INTO IDLE_SESSION
FROM sys.dm_exec_connections CONN
JOIN sys.sysprocesses PROCES 
ON CONN.session_id = PROCES.spid
--Find the idle connection which longer than 30 minutes
WHERE (Datediff(mi,PROCES.last_batch,getdate())>30)
GROUP BY 
CONN.client_net_address,
CONN.session_id,
CONN.connect_time,
PROCES.last_batch,
Datediff(mi,PROCES.last_batch,getdate()),
CONN.last_read,
CONN.last_write,
CONN.most_recent_session_id,CONN.net_transport,
CONN.protocol_type,CONN.protocol_version,CONN.endpoint_id,CONN.encrypt_option,
CONN.auth_scheme,CONN.node_affinity,CONN.num_reads,
CONN.num_writes,CONN.net_packet_size,CONN.client_tcp_port,
CONN.local_net_address,CONN.local_tcp_port,CONN.connection_id,
CONN.parent_connection_id,CONN.most_recent_sql_handle
ORDER BY Datediff(mi,PROCES.last_batch,getdate()) DESC



Thanks.

Walker
