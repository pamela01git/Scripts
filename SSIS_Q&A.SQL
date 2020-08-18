exec [dbo].[SP_START_SETTLEMENT_PACKAGE] 'Is_BmsSetGantryHa_BmsProGantryTx.dtsx','2015-01-01','2015-01-02',''


以下列使用者的身分執行: fetcs\bmsservice。Microsoft (R) SQL Server 執行封裝公用程式  Version 11.0.5058.0 for 64-bit  Copyright (C) Microsoft Corporation. 著作權所有，並保留一切權利。 
   已啟動:  上午 07:23:14  無法執行 IS 伺服器封裝，因為發生錯誤 0x80131904。伺服器: BMS-sitDB-VIP00，封裝路徑: \SSISDB\SETTLEMENT\SETTLEMENT\Is_BmsSetGantryHa_BmsProGantryTx.dtsx
，環境參考識別碼: 1。  描述: 已停用 .NET Framework 中的使用者程式碼執行。請啟用 "clr enabled" 組態選項。  來源: .Net SqlClient Data Provider  
已啟動:  上午 07:23:14  已完成: 上午 07:23:15  經過時間:  0.453 秒.  封裝執行失敗。.  步驟失敗。

==>
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'clr enabled', 1;
GO
RECONFIGURE;
GO



訊息
以下列使用者的身分執行: fetcs\bmsservice。Microsoft (R) SQL Server 執行封裝公用程式  Version 11.0.5058.0 for 64-bit  Copyright (C) Microsoft Corporation. 著作權所有，並保留一切權利。    已啟動:  上午 07:25:28  無法執行 IS 伺服器封裝，因為發生錯誤 0x80131904。伺服器: BMS-sitDB-VIP00，封裝路徑: \SSISDB\SETTLEMENT\SETTLEMENT\Is_BmsSetGantryHa_BmsProGantryTx.dtsx，環境參考識別碼: 1。 
 描述: 嘗試載入組件識別碼 65536 時，Microsoft .NET Framework 發生錯誤。伺服器可能資源不足，或者組件具有 PERMISSION_SET = EXTERNAL_ACCESS 或 UNSAFE 而不受信任。
請再次執行查詢，或參閱文件集，以了解如何解決組件信任問題。如需有關此錯誤的詳細資訊:   System.IO.FileLoadException: 無法載入檔案或組件 'microsoft.sqlserver.integrationservices.server, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91' 或其相依性的其中之一。 發生關於安全性的錯誤。 (發生例外狀況於 HRESULT: 0x8013150A)  System.IO.FileLoadException:      於 System.Reflection.RuntimeAssembly._nLoad(AssemblyName fileName, String codeBase, Evidence assemblySecurity, RuntimeAssembly locationHint, StackCrawlMark& stackMark, IntPtr pPrivHostBinder, Boolean throwOnFileNotFound, Boolean forIntrospection, Boolean suppressSecurityChecks)     於 System.Reflection.RuntimeAssembly.InternalLoadAssemblyName(AssemblyName assemblyRef, Evidence assemblySecurity, RuntimeAssembly reqAssembly, StackCrawlMark& stackMark, IntPtr pPrivHostBinder, Boolean throwOnFileNotFound, Boolean forIntrospection, Boolean suppressSecurityChecks)     於 System.Reflection.RuntimeAssembly.InternalLoad(String assemblyString, Evidence assemblySecurity, StackCrawlMark& stackMark, IntPtr pPrivHostBinder, Boolean forIntrospection)     於 System.Reflection.RuntimeAssembly.InternalLoad(String assemblyString, Evidence assemblySecurity, StackCrawlMark& stackMark, Boolean forIntrospection)    
 於 System.Reflection.Assembly.Load(String assemblyString)  來源: .Net SqlClient Data Provider  已啟動:  上午 07:25:28  已完成: 上午 07:25:31  經過時間:  3.042 秒.  封裝執行失敗。.  步驟失敗。

==>
ALTER DATABASE SSISDB SET TRUSTWORTHY ON;


訊息
以下列使用者的身分執行: fetcs\bmsservice。Microsoft (R) SQL Server 執行封裝公用程式  Version 11.0.5058.0 for 64-bit  Copyright (C) Microsoft Corporation. 著作權所有，並保留一切權利。    已啟動:  上午 07:29:37  無法執行 IS 伺服器封裝，因為發生錯誤 0x80131904。伺服器: BMS-sitDB-VIP00，封裝路徑: \SSISDB\SETTLEMENT\SETTLEMENT\Is_BmsSetGantryHa_BmsProGantryTx.dtsx，環境參考識別碼: 1。  描述: master 資料庫中記錄的資料庫擁有者 SID 與資料庫 'SSISDB' 中記錄的資料庫擁有者 SID 不同。您應該使用 ALTER AUTHORIZATION 陳述式重設資料庫 'SSISDB' 的擁有者，以更正這個狀況。  來源: .Net SqlClient Data Provider  已啟動:  上午 07:29:37  已完成: 上午 07:29:37  經過時間:  0.5 秒.  封裝執行失敗。.  步驟失敗。



--To check who is the owner listed in the master database run the following:


SELECT  SD.[SID]
       ,SL.Name as [LoginName]
  FROM  master..sysdatabases SD inner join master..syslogins SL
    on  SD.SID = SL.SID
 Where  SD.Name = 'ssisdb'


--To check what SID is the DBO in the restored database run the following:


Select [SID]
  From ssisdb.sys.database_principals
 Where Name = 'DBO'

Alter Authorization on Database::[SSISDB] to [FETCP\gordon]
