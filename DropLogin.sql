select 'drop user '+ rtrim(name)
,'drop login '+ rtrim(name)
 from sys.syslogins
where (name like '%Test%' or  name like '%TEST%' or name like '%test%' or name like 'AMSS%')
 and name <> 'AMSS_EAI'
 