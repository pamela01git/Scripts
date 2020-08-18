alter database tempdb
modify file(
name = 'tempdev',
filename = 'F:\TMP_Data\tempdb.mdf')

alter database tempdb
modify file(
name = 'templog',
filename = 'F:\TMP_Data\templog.ldf')