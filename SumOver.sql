DECLARE @Companies TABLE 
  (
CompanyId int, 
 
[Year] int, 
   
Amount int 
) 

INSERT INTO @Companies (CompanyId,[Year],[Amount]) 
VALUES (1,2000,100000),(1,2001,200000),(1,2002,35000), 
       
(2,2000,50000),(2,2001,75000),(2,2002,35000) 

 
SELECT  CompanyId,[Year],Amount, 
        
SUM(Amount) OVER (PARTITION BY CompanyID  ORDER BY [Year]) AS CumulativeRevenue        
FROM @Companies