select s1.column_name,s1.data_type,s2.data_type from tempdb.INFORMATION_SCHEMA.columns s1
 inner join hisdb.information_schema.columns s2 on s2.column_name =s1.column_name and s2.table_name='EMRTChineseDeathCertificate'
where s1.table_name like '%tmp3%'