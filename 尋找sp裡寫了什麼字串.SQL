SELECT name
FROM   sys.procedures
WHERE  Object_definition(object_id) LIKE '%strHell%'


SELECT name
FROM   sys.procedures
WHERE  Object_definition(object_id) LIKE '%PROMDiseases%'
 and name in 
 (
 SELECT name
FROM   sys.procedures
WHERE  Object_definition(object_id) LIKE '%ChronicTypeCode%')