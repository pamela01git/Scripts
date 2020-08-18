1.    使用 OpenRowset

 

SELECT * FROM OpenRowset('MSDASQL', 

  'Driver={Microsoft Text Driver (*.txt; *.csv)};

  DefaultDir=D:\Temp;',

  'SELECT TOP 5 * FROM MyText.txt where region = ''Taipei''')

 

2.    使用 Link Server

 

EXEC sp_addlinkedserver txtserver, 'Jet 4.0',

  'Microsoft.Jet.OLEDB.4.0', 'D:\Temp', NULL, 'Text'

 

SELECT * FROM txtserver...MyTest#txt WHERE region = 'Taipei'

 

 您可以將附件儲存到本機磁碟並修改 D:\Temp 路徑，執行上述語法，看是否可以正常查詢出資料
