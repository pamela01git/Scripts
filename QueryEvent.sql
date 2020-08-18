-- Extract the Event information from the Event Session 
SELECT 
    event_name, 
    timestamp, 
    cpu, 
    duration, 
    reads, 
    writes, 
    state, 
    ISNULL(offset, tsql_stack.value('(frame/@offsetStart)[1]', 'int')) as offset,
    ISNULL(offset_end, tsql_stack.value('(frame/@offsetEnd)[1]', 'int')) as offset_end,
    ISNULL(nest_level, tsql_stack.value('(frame/@level)[1]', 'int')) as nest_level,
    SUBSTRING(sql_text,    
                (ISNULL(offset, tsql_stack.value('(frame/@offsetStart)[1]', 'int'))/2)+1, 
                ((CASE ISNULL(offset_end, tsql_stack.value('(frame/@offsetEnd)[1]', 'int')) 
                    WHEN -1 THEN DATALENGTH(sql_text) 
                    ELSE ISNULL(offset_end, tsql_stack.value('(frame/@offsetEnd)[1]', 'int')) 
                  END - ISNULL(offset, tsql_stack.value('(frame/@offsetStart)[1]', 'int')))/2) + 1) AS statement_text_Xevents,
    sql_text,
    event_sequence,
    activity_id
FROM
(
    SELECT 
        event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
        DATEADD(hh, 
            DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), 
            event_data.value('(event/@timestamp)[1]', 'datetime2')) AS [timestamp],
        COALESCE(event_data.value('(event/data[@name="database_id"]/value)[1]', 'int'), 
            event_data.value('(event/action[@name="database_id"]/value)[1]', 'int')) AS database_id,
        event_data.value('(event/action[@name="session_id"]/value)[1]', 'int') AS [session_id],
        event_data.value('(event/data[@name="cpu"]/value)[1]', 'int') AS [cpu],
        event_data.value('(event/data[@name="duration"]/value)[1]', 'bigint') AS [duration],
        event_data.value('(event/data[@name="reads"]/value)[1]', 'bigint') AS [reads],
        event_data.value('(event/data[@name="writes"]/value)[1]', 'bigint') AS [writes],
        event_data.value('(event/data[@name="state"]/text)[1]', 'nvarchar(4000)') AS [state],
        event_data.value('(event/data[@name="offset"]/value)[1]', 'int') AS [offset],
        event_data.value('(event/data[@name="offset_end"]/value)[1]', 'int') AS [offset_end],
        event_data.value('(event/data[@name="nest_level"]/value)[1]', 'int') AS [nest_level],
        CAST(event_data.value('(event/action[@name="tsql_stack"]/value)[1]', 'nvarchar(4000)') AS XML) AS [tsql_stack],
        event_data.value('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS [sql_text],
        event_data.value('(event/data[@name="source_database_id"]/value)[1]', 'int') AS [source_database_id],
        event_data.value('(event/data[@name="object_id"]/value)[1]', 'int') AS [object_id],
        event_data.value('(event/data[@name="object_type"]/text)[1]', 'int') AS [object_type],
        CAST(SUBSTRING(event_data.value('(event/action[@name="attach_activity_id"]/value)[1]', 'varchar(50)'), 1, 36) AS uniqueidentifier) as activity_id,
        CAST(SUBSTRING(event_data.value('(event/action[@name="attach_activity_id"]/value)[1]', 'varchar(50)'), 38, 10) AS int) as event_sequence
    FROM 
    (   SELECT XEvent.query('.') AS event_data 
        FROM 
        (    -- Cast the target_data to XML 
            SELECT CAST(target_data AS XML) AS TargetData 
            FROM sys.dm_xe_session_targets st 
            JOIN sys.dm_xe_sessions s 
                ON s.address = st.event_session_address 
            WHERE name = 'SQLStmtEvents' 
              AND target_name = 'ring_buffer'
        ) AS Data 
        -- Split out the Event Nodes 
        CROSS APPLY TargetData.nodes ('RingBufferTarget/event') AS XEventData (XEvent)   
    ) AS tab (event_data)
) AS results