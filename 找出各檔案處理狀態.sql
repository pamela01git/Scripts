--給予各JOB_STAGE權數
with CTE_JobStageWeight (datacat,job_stage,JobStageWeight)
as
(
   select datacat,SUBSTRING(JOB_NAME,11,LEN(RTRIM(JOB_NAME))-10),job_seq * 100
   from  ismd.odsdba.xbatchflow
   where datacat = job_stage
)

SELECT A1.DATACAT,A1.DATACATNM,A1.JOB_LOCATION,A1.NAME,CASE WHEN RUN_STATUS <> 'RUNOK' THEN S9.LBSDT ELSE A1.CYCLE_END END
FROM 
(
 select S1.DATACAT,S3.DATACATNM,S1.JOB_LOCATION,s4.name,run_status,S1.CYCLE_END,S1.job_name 
 from  ismd.odsdba.xbatchflow s1
      ,CTE_JobStageWeight s2
      ,ISMD.ODSDBA.XFLOWDETAIL S3
      ,(
        SELECT  replace(name,'_','') as TMP_Name,name    
        FROM ODSDB.dbo.sysobjects t
         where  uid in (5,6)
           AND  odsdb.dbo.instr(name,'_',1) in ('CB','CS','FB','FS','MD','TX','CRM','ODS','ODSMS')
           and  isnumeric(right(name,6)) = 0
        UNION ALL
        SELECT  replace(name,'_','') as TMP_Name,name    
        FROM crmbasisdb.dbo.sysobjects t
         where  uid in (5,6)
           AND  odsdb.dbo.instr(name,'_',1) in ('CB','CS','FB','FS','MD','TX','CRM','ODS','ODSMS')
           and  isnumeric(right(name,6)) = 0
        UNION ALL
        SELECT  replace(name,'_','') as TMP_Name,name    
        FROM REPORTDB.dbo.sysobjects t
         where  uid in (5,6)
           AND  odsdb.dbo.instr(name,'_',1) in ('CB','CS','FB','FS','MD','TX','CRM','ODS','ODSMS')
           and  isnumeric(right(name,6)) = 0   
        UNION ALL
        SELECT  replace(name,'_','') as TMP_Name,name    
        FROM PCUINFODB.dbo.sysobjects t
         where  uid in (5,6)
           AND  odsdb.dbo.instr(name,'_',1) in ('CB','CS','FB','FS','MD','TX','CRM','ODS','ODSMS')
           and  isnumeric(right(name,6)) = 0   
        UNION ALL
        SELECT  replace(name,'_','') as TMP_Name,name    
        FROM PCUCAMPDB.dbo.sysobjects t
         where  uid in (5,6)
           AND  odsdb.dbo.instr(name,'_',1) in ('CB','CS','FB','FS','MD','TX','CRM','ODS','ODSMS')
           and  isnumeric(right(name,6)) = 0    
        UNION ALL
        SELECT  replace(name,'_','') as TMP_Name,name    
        FROM PCUSEGDB.dbo.sysobjects t
         where  uid in (5,6)
           AND  odsdb.dbo.instr(name,'_',1) in ('CB','CS','FB','FS','MD','TX','CRM','ODS','ODSMS')
           and  isnumeric(right(name,6)) = 0    
        UNION ALL
        SELECT  replace(name,'_','') as TMP_Name,name    
        FROM MISRPTDB.dbo.sysobjects t
         where  uid in (5,6)
           AND  odsdb.dbo.instr(name,'_',1) in ('CB','CS','FB','FS','MD','TX','CRM','ODS','ODSMS')
           and  isnumeric(right(name,6)) = 0       
       ) S4
 where  s2.datacat = s1.datacat
   AND  S2.job_stage = s1.job_stage
   AND  S3.DATACAT=S1.DATACAT
   AND  s4.TMP_Name=odsdb.dbo.instr(s1.job_name,'_',3)
   and  REPLACE(S1.DATACAT+CONVERT(VARCHAR,s2.JobStageWeight+(JOB_FLOW*10)+job_seq),' ','') 
     in 
       (   
       select REPLACE(DATACAT+CONVERT(VARCHAR,max(JobWeight)),' ','') as maxseq
       from (
              select S1.DATACAT,s1.job_name,s2.JobStageWeight+(JOB_FLOW*10)+job_seq as JobWeight 
              from ismd.odsdba.xbatchflow s1
                  ,CTE_JobStageWeight s2
              where s2.datacat = s1.datacat
                and s2.job_stage = s1.job_stage
                AND s1.datacat <> s1.job_stage
                AND s1.job_seq <> 1
                and s1.job_name not in ('WaitingRunning','WaitForJob','SP_ODS_FLOW_UPD','SP_ODS_FLOW_INS') 
                AND LEFT(S1.JOB_NAME,2) <> 'IS'
                AND LEFT(S1.JOB_NAME,6) NOT IN ('SP_TX_','SP_FB_')
                AND LEFT(odsdb.dbo.instr(s1.job_name,'_',3),3) <> 'TMP'           
            ) as a
       group by DATACAT,odsdb.dbo.instr(job_name,'_',3)
       )
 UNION ALL       
 SELECT S1.DATACAT,S3.DATACATNM,S1.JOB_LOCATION,s1.PARAM,S1.run_status,S1.CYCLE_END,S1.job_name  
 FROM ISMD.ODSDBA.XBATCHFLOW S1
     ,ISMD.ODSDBA.XFLOWDETAIL S3
 WHERE S3.DATACAT= S1.DATACAT
   AND job_name  in ('SP_ODS_FLOW_UPD','SP_ODS_FLOW_INS')
 UNION ALL
 SELECT S1.DATACAT,S3.DATACATNM,S1.JOB_LOCATION,'ODS_'+LEFT(odsdb.dbo.instr(s1.job_name,'_',2),2)+'_'+SUBSTRING(odsdb.dbo.instr(s1.job_name,'_',2),3,LEN(odsdb.dbo.instr(s1.job_name,'_',2))-2),S1.run_status,S1.CYCLE_END,S1.job_name
 FROM ISMD.ODSDBA.XBATCHFLOW S1
     ,ISMD.ODSDBA.XFLOWDETAIL S3
 WHERE S3.DATACAT= S1.DATACAT
   AND LEFT(S1.JOB_NAME,2) = 'IS'
 UNION ALL
 SELECT  S1.DATACAT,S3.DATACATNM,S1.JOB_LOCATION,SUBSTRING(JOB_NAME,4,LEN(JOB_NAME)-3),S1.run_status,S1.CYCLE_END,S1.job_name
 FROM ISMD.ODSDBA.XBATCHFLOW S1
     ,ISMD.ODSDBA.XFLOWDETAIL S3
 WHERE S3.DATACAT= S1.DATACAT
   AND LEFT(S1.JOB_NAME,6) IN ('SP_TX_','SP_FB_')
) A1
,CRMBASISDB.ODSDBA.CB_DT S9
WHERE S9.DATADT = A1.CYCLE_END
ORDER BY DATACATNM