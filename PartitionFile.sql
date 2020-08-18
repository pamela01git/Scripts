http://msdn.microsoft.com/en-us/library/ms188071.aspx
SELECT * FROM Production.TransactionHistory
WHERE $PARTITION.TransactionRangePF1(TransactionDate) = 5 ;
