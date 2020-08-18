在缺乏 Tempdb的狀況下重開 SQL Server
最近在客戶那邊遇到很特別的狀況，存放 SQL Server Database的 Storage毀了。Disk crashed不是什麼罕見的事，也不見得是大災難，因為大部分 Storage都有用 RAID架構來保護，這次毀掉的是 RAID 5，理論上，只要有一顆 Disk出了問題，Hot-spare馬上就會 switch過去，可是因為是測試環境，把 Hot-spare給省掉了，這也並非沒救，只要在出問題的時候，儘快抽換掉有問題的 Disk，還是有可能救回來。問題來了，如果同一個 RAID 5同時壞 2顆 Disk怎麼辦？這種百年難得一見的情形，買樂透吧！

 

 Storage毀了，代表 Database只能從備份救回來，那 System Database呢？通常 SQL Server系統的部分，都放在伺服器 Local Disk，而這部分絕大部分是 RAID 1，要掛掉更難，可是 System Database裡，有個 TempDB，因為使用量與成長量都大，通常會放到外掛的 Storage，因此在這次的災難中也一併掛掉了，導致 SQL Server的 Service也起不來了，這該怎麼辦呢？ 我們先瞭解一下 TempDB的特性，TempDB在每次 SQL Server start時都會重建，雖然在開啟時因為找不到 TempDB而無法啟動，但是不需找回原來的 TempDB，只要把 TempDB的路徑只到別的地方就可以了。重點來了，我們還是得先把 SQL Server開起來才能改路徑，因此，要先把 SQL Server在 maser-only mode開啟，語法如下： 

NET START MSSQLSERVER /f /T3608

 

如果是特定的 Instance，則用： 

NET START MSSQL$instancename /f /T3608

 

接下來，利用 sqlcmd來重設路徑 

ALTER DATABASE database_name MODIFY FILE( NAME = logical_name , FILENAME = 'new_path\os_file_name' )

 

以 TempDB來說，以下是個範例： 

USE master; 

GO 

ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev, FILENAME = 'c:\tempdb.mdf'); 

GO 

ALTER DATABASE tempdb MODIFY FILE (NAME = templog, FILENAME = 'c:\templog.ldf'); 

GO

sqlcmd -q "ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev, FILENAME = 'c:\tempdb.mdf');ALTER DATABASE tempdb MODIFY FILE (NAME = templog, FILENAME = 'c:\templog.ldf'); "

最後重新啟動 SQL Server，會發現在新指定的目錄下，出現了新的 TempDB，當然，SQL Server也能順利運作了。 
Setup /QUIET /ACTION=REBUILDDATABASE /INSTANCENAME=MSSQLSERVER /SQLSYSADMINACCOUNTS=sa /SAPWD= Zaq12wsx [ /SQLCOLLATION=CollationName] 
