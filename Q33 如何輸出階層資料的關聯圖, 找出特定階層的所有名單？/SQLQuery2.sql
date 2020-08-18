USE AdventureWorks;
GO
--Creates an infinite loop
WITH cte (EmployeeID, ManagerID, Title) as
(
    SELECT EmployeeID, ManagerID, Title
    FROM HumanResources.Employee
    WHERE ManagerID IS NOT NULL
  UNION ALL
    SELECT cte.EmployeeID, cte.ManagerID, cte.Title
    FROM cte 
    JOIN  HumanResources.Employee AS e 
        ON cte.ManagerID = e.EmployeeID
)
--Uses MAXRECURSION to limit the recursive levels to 2
SELECT EmployeeID, ManagerID, Title
FROM cte
--OPTION (MAXRECURSION 0);
GO

--Correct Way to find root data
;WITH cte (EmployeeID,loginid, ManagerID,lvl,sort, Title) as
(
    SELECT EmployeeID,loginid, ManagerID,0 as lvl,cast(EmployeeID as varbinary(max)), Title
    FROM HumanResources.Employee
    WHERE ManagerID IS NULL
  UNION ALL 
    SELECT e.EmployeeID,e.loginid, e.ManagerID,cte.lvl+1,Sort+cast(e.EmployeeID as varbinary(max)),e.Title
    --cte.EmployeeID, cte.ManagerID, cte.Title, 
    FROM HumanResources.Employee AS e
    JOIN  cte
        ON (e.managerID=cte.EmployeeID )
)
-- Notice the MAXRECURSION option is removed
SELECT * FROM cte
GO