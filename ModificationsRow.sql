
SELECT 
SCHEMA_NAME(tbls.uid)  as table_schema,
tbls.name as table_name, 
i.name as index_name, 
i.id as table_id, 
i.indid as index_id, 
i.rowmodctr as modifiedRows, 
(select max(rowcnt) from sysindexes i2 where i.id = i2.id and i2.indid < 2) as rowcnt, 
convert(DECIMAL(18,8), convert(DECIMAL(18,8),i.rowmodctr) / convert(DECIMAL(18,8), 
(select max(rowcnt) from sysindexes i2 where i.id = i2.id and i2.indid < 2))) as ModifiedPercent, 
stats_date( i.id, i.indid ) as lastStatsUpdate
from sysindexes i 
left outer join sysobjects tbls on i.id = tbls.id 
left outer join sysusers schemas on tbls.uid = schemas.uid 
left outer join information_schema.tables tl 
on tbls.name = tl.table_name 
and tl.table_type='BASE TABLE' 
where i.indid >0 
and i.indid < 255 
and table_schema <> 'sys' 
and i.rowmodctr > 0  
--and (i.rowmodctr > 0  OR DATEDIFF(minute,stats_date( i.id, i.indid ) ,GETDATE()) <= 30)
--and i.status not in (8388704,8388672)  -- Auto created stats
and (select max(rowcnt) from sysindexes i2 where i.id = i2.id and i2.indid < 2) > 0 


----------------

,('BMS_OD_FCCTRL')
,('BMS_OD_FCITEM')
,('BMS_OD_FCLIST')
,('BMS_OD_FCRETURN')
,('BMS_OD_FCRETURN_ITEM')
,('BMS_OD_LOOKUP_LOG')
,('BMS_RM_BAD_DEBT_BATCH')
,('BMS_RM_BAD_DEBT_DETAIL')
,('BMS_RM_FORCE_EX_BATCH')
,('BMS_RM_FORCE_EX_DETAIL')
,('BMS_RM_BILL_INFO')
,('BMS_RM_BOX')
,('BMS_RM_DELIVERY_INFO')
,('BMS_RM_DELIVERY_STATUS')
,('BMS_RM_MAIL_CD')
,('BMS_RM_MAIL_IMG')
,('BMS_RM_RECEIPT_DUP')
,('BMS_RM_RECEIPT_IMG')
,('BMS_VT_MASTER')
,('BMS_VT_TRANS_DETAIL')
,('BMS_VL_BILL')
,('BMS_VL_BILL_DETAIL')
,('BMS_VL_DETAIL')
,('BMS_VL_LPR')
,('BMS_VL_LPR_INVOICE')
,('BMS_VL_LOG')
,('BMS_VL_LICENSE_STATUS')
,('BMS_VL_RECV_REGISTERED_ERROR')
,('BMS_VL_PAYMENT')
,('BMS_VL_PAYMENT_FORMAT')
,('BMS_VL_REPAY')
,('BMS_VL_WOF')
,('BMS_VL_TICKET_DETAIL')
,('BMS_VL_ERR_LINE')
,('BMS_VL_INVOICE')
,('BMS_VL_INVOICE_DETAIL')
,('BMS_VL_INVOICE_MASTER')
,('BMS_VL_BILL_ADDR')
,('BMS_VL_CHARGE_INFO')
,('BMS_RF_DETAIL')
,('BMS_RF_MASTER')
,('BMS_RF_REFUND_TO_VTP')
,('BMS_OT_LOOKUP_TYPE')
,('BMS_OT_LOOKUP_CODE')
