select top 100 *
from odsdba.FB_ACMR_DH
where $PARTITION.CRMBASISDB_PF_FB(datadt)=29 
 
 
 
 select distinct $partition.CRMBasisDB_Pf_CS(datadt)  from odsdba.CS_Pcust_Collect_ms


select custkey from  odsdba.CS_Pcust_Collect_ms where $partition.CRMBasisDB_Pf_CS(datadt) =29

sp_helpdb 'crmbasisdb'

select * from odsdba.CS_Pcust_Collect_ms
select $partition.PF1(a) , a, b from t1

where $PARTITION.CRMBASISDB_PF_FB(datadt)=29 
 
 select top 100 $partition.CRMBASISDB_PF_tx(datadt),*
from dwbasisdb.odsdba.tx_mgtinfo
