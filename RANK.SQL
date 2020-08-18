USE AdventureWorks;
GO
SELECT c.FirstName, c.LastName
    ,ROW_NUMBER() OVER (ORDER BY a.PostalCode) AS 'Row Number'
    ,RANK() OVER (ORDER BY a.PostalCode) AS 'Rank'
    ,DENSE_RANK() OVER (ORDER BY a.PostalCode) AS 'Dense Rank'
    ,NTILE(4) OVER (ORDER BY a.PostalCode) AS 'Quartile'
    ,s.SalesYTD, a.PostalCode
FROM Sales.SalesPerson s 
    INNER JOIN Person.Contact c 
        ON s.SalesPersonID = c.ContactID
    INNER JOIN Person.Address a 
        ON a.AddressID = c.ContactID
WHERE TerritoryID IS NOT NULL 
    AND SalesYTD <> 0;
http://msdn2.microsoft.com/en-us/library/ms189798.aspx
 
 
 SELECT ROW_NUMBER() OVER ( order by convert(int,replace(S1.reserved,'KB',' ')) desc) AS SEQ,*
 from odsdba.MD_TABLEUsage S1