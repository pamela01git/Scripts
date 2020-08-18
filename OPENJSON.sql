DECLARE @jsonData NVARCHAR(MAX)
select @jsondata=productjson from [dbo].[FormSalesOrderItem]
where formno='2016101700321'
order by createtime 


select @jsondata

 SELECT *   
 FROM OPENJSON(@jsondata)  
 WITH (┐дел nvarchar(50))  