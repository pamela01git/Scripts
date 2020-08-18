1.將xp_cmdshell的services打開
   sql server surface area->surface area configaration for features
   ->enable
   
2.建立一個proxy user
  EXEC sp_xp_cmdshell_proxy_account 'SHIPPING\KobeR','sdfh%dkc93vcMt0'
  
3.grant exec permisioon to sql user
ex:grant execute on xp_cmdshell to odsdba

From the Sidebar:Enabling xp_cmdshell
/*Execute this on the master database */
Use master
Go

Exec sp_configure 'show advanced options', 1
Go
Reconfigure with override
Go
Exec sp_configure 'xp_cmdshell', 1
Go
Reconfigure with override
Go