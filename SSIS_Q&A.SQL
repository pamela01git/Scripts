exec [dbo].[SP_START_SETTLEMENT_PACKAGE] 'Is_BmsSetGantryHa_BmsProGantryTx.dtsx','2015-01-01','2015-01-02',''


�H�U�C�ϥΪ̪���������: fetcs\bmsservice�CMicrosoft (R) SQL Server ����ʸˤ��ε{��  Version 11.0.5058.0 for 64-bit  Copyright (C) Microsoft Corporation. �ۧ@�v�Ҧ��A�ëO�d�@���v�Q�C 
   �w�Ұ�:  �W�� 07:23:14  �L�k���� IS ���A���ʸˡA�]���o�Ϳ��~ 0x80131904�C���A��: BMS-sitDB-VIP00�A�ʸ˸��|: \SSISDB\SETTLEMENT\SETTLEMENT\Is_BmsSetGantryHa_BmsProGantryTx.dtsx
�A���ҰѦ��ѧO�X: 1�C  �y�z: �w���� .NET Framework �����ϥΪ̵{���X����C�бҥ� "clr enabled" �պA�ﶵ�C  �ӷ�: .Net SqlClient Data Provider  
�w�Ұ�:  �W�� 07:23:14  �w����: �W�� 07:23:15  �g�L�ɶ�:  0.453 ��.  �ʸ˰��楢�ѡC.  �B�J���ѡC

==>
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'clr enabled', 1;
GO
RECONFIGURE;
GO



�T��
�H�U�C�ϥΪ̪���������: fetcs\bmsservice�CMicrosoft (R) SQL Server ����ʸˤ��ε{��  Version 11.0.5058.0 for 64-bit  Copyright (C) Microsoft Corporation. �ۧ@�v�Ҧ��A�ëO�d�@���v�Q�C    �w�Ұ�:  �W�� 07:25:28  �L�k���� IS ���A���ʸˡA�]���o�Ϳ��~ 0x80131904�C���A��: BMS-sitDB-VIP00�A�ʸ˸��|: \SSISDB\SETTLEMENT\SETTLEMENT\Is_BmsSetGantryHa_BmsProGantryTx.dtsx�A���ҰѦ��ѧO�X: 1�C 
 �y�z: ���ո��J�ե��ѧO�X 65536 �ɡAMicrosoft .NET Framework �o�Ϳ��~�C���A���i��귽�����A�Ϊ̲ե�㦳 PERMISSION_SET = EXTERNAL_ACCESS �� UNSAFE �Ӥ����H���C
�ЦA������d�ߡA�ΰѾ\��󶰡A�H�F�Ѧp��ѨM�ե�H�����D�C�p�ݦ��������~���ԲӸ�T:   System.IO.FileLoadException: �L�k���J�ɮשβե� 'microsoft.sqlserver.integrationservices.server, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91' �Ψ�̩ۨʪ��䤤���@�C �o������w���ʪ����~�C (�o�ͨҥ~���p�� HRESULT: 0x8013150A)  System.IO.FileLoadException:      �� System.Reflection.RuntimeAssembly._nLoad(AssemblyName fileName, String codeBase, Evidence assemblySecurity, RuntimeAssembly locationHint, StackCrawlMark& stackMark, IntPtr pPrivHostBinder, Boolean throwOnFileNotFound, Boolean forIntrospection, Boolean suppressSecurityChecks)     �� System.Reflection.RuntimeAssembly.InternalLoadAssemblyName(AssemblyName assemblyRef, Evidence assemblySecurity, RuntimeAssembly reqAssembly, StackCrawlMark& stackMark, IntPtr pPrivHostBinder, Boolean throwOnFileNotFound, Boolean forIntrospection, Boolean suppressSecurityChecks)     �� System.Reflection.RuntimeAssembly.InternalLoad(String assemblyString, Evidence assemblySecurity, StackCrawlMark& stackMark, IntPtr pPrivHostBinder, Boolean forIntrospection)     �� System.Reflection.RuntimeAssembly.InternalLoad(String assemblyString, Evidence assemblySecurity, StackCrawlMark& stackMark, Boolean forIntrospection)    
 �� System.Reflection.Assembly.Load(String assemblyString)  �ӷ�: .Net SqlClient Data Provider  �w�Ұ�:  �W�� 07:25:28  �w����: �W�� 07:25:31  �g�L�ɶ�:  3.042 ��.  �ʸ˰��楢�ѡC.  �B�J���ѡC

==>
ALTER DATABASE SSISDB SET TRUSTWORTHY ON;


�T��
�H�U�C�ϥΪ̪���������: fetcs\bmsservice�CMicrosoft (R) SQL Server ����ʸˤ��ε{��  Version 11.0.5058.0 for 64-bit  Copyright (C) Microsoft Corporation. �ۧ@�v�Ҧ��A�ëO�d�@���v�Q�C    �w�Ұ�:  �W�� 07:29:37  �L�k���� IS ���A���ʸˡA�]���o�Ϳ��~ 0x80131904�C���A��: BMS-sitDB-VIP00�A�ʸ˸��|: \SSISDB\SETTLEMENT\SETTLEMENT\Is_BmsSetGantryHa_BmsProGantryTx.dtsx�A���ҰѦ��ѧO�X: 1�C  �y�z: master ��Ʈw���O������Ʈw�֦��� SID �P��Ʈw 'SSISDB' ���O������Ʈw�֦��� SID ���P�C�z���Өϥ� ALTER AUTHORIZATION ���z�����]��Ʈw 'SSISDB' ���֦��̡A�H�󥿳o�Ӫ��p�C  �ӷ�: .Net SqlClient Data Provider  �w�Ұ�:  �W�� 07:29:37  �w����: �W�� 07:29:37  �g�L�ɶ�:  0.5 ��.  �ʸ˰��楢�ѡC.  �B�J���ѡC



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