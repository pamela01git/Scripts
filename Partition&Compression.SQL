  SELECT s2.name,case when max(PARTITION_NUMBER)= 1 then 'N' else 'Y' end Partition_Flag
                           ,case when max(s1.data_compression_desc)='NONE' then 'N' else 'Y' end Compression_Flag
                            FROM sys.partitions S1
                                 INNER JOIN SYS.TABLES S2 ON (S1.OBJECT_ID=S2.OBJECT_ID)
                            where S2.create_date > '20091201'     
                           group by S2.name
                           order by s2.name