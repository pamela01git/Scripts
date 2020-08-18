select * from sys.dm_os_wait_stats
order by 3 desc

select lastwaittype,count(1) from sys.sysprocesses
group by lastwaittype 
where lastwaittype like 'lck%'