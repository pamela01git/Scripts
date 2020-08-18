select b.name as Table_Name,a.name as Column_Name 
from sys.identity_columns as a inner join sys.objects as b 
on a.object_id=b.object_id 
where type='U'