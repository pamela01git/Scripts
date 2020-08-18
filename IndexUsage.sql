SELECT   OBJECT_NAME(S.[OBJECT_ID]) AS [OBJECT NAME]
,          I.[NAME] AS [INDEX NAME]
,          USER_SEEKS,          USER_SCANS,          USER_LOOKUPS,          USER_UPDATES 
FROM     SYS.DM_DB_INDEX_USAGE_STATS AS S         
 INNER JOIN SYS.INDEXES AS I            ON I.[OBJECT_ID] = S.[OBJECT_ID]               AND I.INDEX_ID = S.INDEX_ID 
 WHERE    OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1 
   and OBJECT_NAME(S.[OBJECT_ID]) in ('bms_rat_tx_batch','bms_pro_transaction','bms_pro_gantry_tx','BMS_RAT_BATCH_DISCOUNTS','BMS_RAT_RATINGS_BY_MILEAGE')