select	t.name as TableName, d.name as FilegroupName 
from	sys.data_spaces d, sys.tables t, sys.indexes i
where	i.object_id = t.object_id 
and		d.data_space_id = i.data_space_id
and		i.index_id < 2
and d.name in (select name from sys.partition_schemes)
order by 2,1
