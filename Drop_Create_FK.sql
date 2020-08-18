
 SELECT 


 * 


 ,'IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N''' + ForeignKeyName +''') AND parent_object_id = OBJECT_ID(N'+''''+ FKTableSchema +'.' + FKTableName + ''')) ALTER TABLE ['+ FKTableSchema +'].[' + FKTableName + '] DROP CONSTRAINT [' + ForeignKeyName +']' AS FKDrop 


 ,'IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N''' + ForeignKeyName +''') AND parent_object_id = OBJECT_ID(N'+''''+ FKTableSchema +'.' + FKTableName + ''')) ALTER TABLE ['+ FKTableSchema +'].[' +FKTableName + '] WITH CHECK ADD  CONSTRAINT  [' + ForeignKeyName + '] FOREIGN KEY(' + 


  FKColumnList +') REFERENCES ['+ PKTableSchema+'].['+ PKTableName + '] ('+PKColumnList +')' AS FKCreate 


 ,'ALTER TABLE ['+ PKTableSchema +'].[' +PKTableName + '] DROP CONSTRAINT ' + PrimaryKeyName AS PKDrop 


 ,'ALTER TABLE ['+PKTableSchema +'].[' +PKTableName + '] ADD CONSTRAINT ' + PrimaryKeyName + ' PRIMARY KEY('+PKColumnList+')' AS PKCreate 


 FROM 


 ( 


 SELECT 


  DISTINCT 


  FKTableSchema=(SELECT DISTINCT table_schema FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE constraint_name=rc.constraint_Name), 


  FKTableName=(SELECT DISTINCT table_Name FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE constraint_name=rc.constraint_Name), 


  rc.constraint_name AS ForeignKeyName, 


  FKColumnList=(SELECT left(t.column_name,len(t.column_name)-1) AS 'ColumnList' FROM 


  ( 


  SELECT Column_Name + ',' FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 


  WHERE constraint_name=rc.constraint_name 
   order by ORDINAL_POSITION


  FOR XML PATH('') 


  ) AS t(column_Name)), 


  cu.table_schema AS PKTableSchema, 


  cu.table_name AS PKTableName, 


  cu.constraint_Name AS PrimaryKeyName, 


  PKColumnList=(SELECT left(t.column_name,len(t.column_name)-1) AS 'ColumnList' FROM 


  ( 


  SELECT Column_Name + ',' FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 


  WHERE constraint_name=cu.constraint_name 
  order by ORDINAL_POSITION


  for xml path('') 


  ) AS t(column_Name)) 


 FROM 


  INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS cu 


 INNER JOIN 


  INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS AS rc 


 ON 


  rc.Unique_Constraint_name= cu.Constraint_name 



 --WHERE 


 -- table_name='department' --and table_schema='sales' 


 ) AS tab 


   

