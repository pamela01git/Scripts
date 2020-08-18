select c.name 
from  sys.tables          t
join  sys.indexes         i 
      on(i.object_id = t.object_id 
      and i.index_id < 2)
join  sys.index_columns  ic 
      on(ic.partition_ordinal > 0 
      and ic.index_id = i.index_id and ic.object_id = t.object_id)
join  sys.columns         c 
      on(c.object_id = ic.object_id 
      and c.column_id = ic.column_id)
where t.object_id  = object_id('bms_pro_gantry_Tx')
