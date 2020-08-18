SELECT * FROM sysjobhistory WHERE JOB_ID IN (SELECT JOB_ID FROM SYSJOBS WHERE NAME= 'TT') AND STEP_ID <>0

1) 

USE msdb

GO

SELECT * FROM sysjobhistory

 

2)

USE msdb

GO

SELECT * FROM sysjobs

 

3)

USE msdb

GO

SELECT * FROM sysjobschedules

 

4)

USE msdb

GO

SELECT * FROM sysjobservers

 

5)

USE msdb

GO

SELECT * FROM sysjobsteps 
