--建立自我參閱的員工資料表
if exists(select * from sys.tables where name='Employees')
drop table Employees
go
CREATE TABLE Employees
(
  empid     int  NOT NULL PRIMARY KEY ,   --員工編號
  mgrid     int          	NULL,            --主管編號
  empname varchar(25) 		NOT NULL,       --員工姓名
  salary     money         NOT NULL,       --薪資
  CONSTRAINT FK_Employees_mgrid_empid
  FOREIGN KEY(mgrid)
  REFERENCES Employees(empid)  --主管編號需要存在員工編號中
)
GO

--輸入每一個員工的基本資料
INSERT INTO Employees VALUES(1 , NULL, 'Nancy'   , $10000.00)
INSERT INTO Employees VALUES(2 , 1   , 'Andrew'  , $5000.00)
INSERT INTO Employees VALUES(3 , 1   , 'Janet'   , $5000.00)
INSERT INTO Employees VALUES(4 , 1   , 'Margaret', $5000.00) 
INSERT INTO Employees VALUES(5 , 2   , 'Steven'  , $2500.00)
INSERT INTO Employees VALUES(6 , 2   , 'Michael' , $2500.00)
INSERT INTO Employees VALUES(7 , 3   , 'Robert'  , $2500.00)
INSERT INTO Employees VALUES(8 , 3   , 'Laura'   , $2500.00)
INSERT INTO Employees VALUES(9 , 3   , 'Ann'     , $2500.00)
INSERT INTO Employees VALUES(10, 4   , 'Ina'     , $2500.00)
INSERT INTO Employees VALUES(11, 7   , 'David'   , $2000.00)
INSERT INTO Employees VALUES(12, 7   , 'Ron'     , $2000.00)
INSERT INTO Employees VALUES(13, 7   , 'Dan'     , $2000.00)
INSERT INTO Employees VALUES(14, 11  , 'James'   , $1500.00)
GO



;WITH EmpCTE(empid, empname, mgrid, lvl,sort,Salary)
AS
( 
-- 錨點成員
SELECT empid, empname, mgrid, 0,
cast(empid as varbinary(max)),Salary
  FROM Employees
  WHERE empid = 1      --初始員工編號
UNION ALL  --將CTE的錨點成員與遞迴成員合併輸出
-- 遞迴成員
SELECT E.empid, E.empname, E.mgrid, M.lvl+1,
Sort+cast(e.empid as varbinary(max)),e.Salary
  FROM Employees AS E
    JOIN EmpCTE AS M   --合併CTE物件進行JOIN查詢
      ON E.mgrid = M.empid
)
SELECT REPLICATE('_',lvl*2)+empname+
'('+convert(varchar(30),empid)+')' '員工階層',
mgrid '主管編號',lvl '階層'
FROM   EmpCTE
Order by sort
GO

-------------
;WITH EmpCTE(empid, empname, mgrid, lvl,sort,Salary)
AS
( 
  --錨點成員
  SELECT empid, empname, mgrid, 0,
cast(empid as varbinary(max)),Salary
  FROM Employees
  WHERE empid = 14 --起始子節點
  UNION ALL  
  --遞迴成員
  SELECT m.empid, m.empname, m.mgrid, e.lvl+1,
sort+cast(m.empid as varbinary(max)),m.Salary
  FROM  Employees AS m
    JOIN EmpCTE AS e
      ON m.empid = e.mgrid --注意Join方式
)
SELECT 
REPLICATE('_',((select max(lvl) from EmpCTE)-lvl)*2)+
empname+'('+convert(varchar(30),empid)+')' 
'員工階層',mgrid  '主管編號',lvl '階層'
FROM EmpCTE
Order by sort desc
GO
