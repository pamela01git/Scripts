c:
cd C:\Program Files\Microsoft SQL Server\90\COM
tablediff -sourceserver 10.253.22.40 -sourcedatabase odsdb -sourcetable cb_dt -sourceschema odsdba -sourceuser sa -sourcepassword crmgroup -destinationserver 10.253.22.40 -destinationdatabase  ismd -destinationtable cb_dt -destinationschema odsdba -destinationuser sa -destinationpassword crmgroup -o d:\temp\1.txt
