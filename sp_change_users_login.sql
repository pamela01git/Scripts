use dmci

EXEC sp_change_users_login 'Report'
 GO

 EXEC sp_change_users_login 'Auto_Fix', 'CI_admin', NULL, 'Ci123456';


EXEC sp_change_users_login 'Update_One', 'GDW_Admin', 'DMCI';
GO