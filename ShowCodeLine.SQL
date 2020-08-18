create  PROC odsdba.ShowCodeLine
(
	@SPID smallint,
	@WAIT tinyint = 0,
	@NoLoop bit = 0
)
AS
BEGIN
	--Author: Narayana Vyas Kondreddi
	--Date Created: 20031016
	--Source: http://vyaskn.tripod.com
 
	SET NOCOUNT ON
 
	DECLARE @sql_handle binary(20), @handle_found bit
	DECLARE @stmt_start int, @stmt_end int
	DECLARE @line nvarchar(4000), @wait_str varchar(8)
 
	SET @handle_found = 0
 
	IF @WAIT NOT BETWEEN 0 AND 60
	BEGIN
		RAISERROR('Valid values for @WAIT are from 0 to 60 seconds', 16, 1)
		RETURN -1
	END
	ELSE
	BEGIN
		SET @wait_str = '00:00:' + RIGHT('00' + CAST(@WAIT AS varchar(2)), 2)
	END
 
	WHILE 1 = 1
	BEGIN
		SELECT	@sql_handle = sql_handle,
			@stmt_start = stmt_start/2,
			@stmt_end = CASE WHEN stmt_end = -1 THEN -1 ELSE stmt_end/2 END
			FROM master.dbo.sysprocesses
			WHERE	spid = @SPID
				AND ecid = 0
  
		IF @sql_handle = 0x0
		BEGIN
			IF @handle_found = 0
			BEGIN
				RAISERROR('Cannot find handle or the SPID is invalid', 16, 1)
				RETURN -1
			END
			ELSE
			BEGIN
				RAISERROR('Query/Stored procedure completed', 0, 1)
				RETURN 0
			END
		END
		ELSE
		BEGIN
			SET @handle_found = 1
		END
 
		SET @line = 
		(
			SELECT 
				SUBSTRING(	text,
						COALESCE(NULLIF(@stmt_start, 0), 1),
						CASE @stmt_end 
							WHEN -1 
								THEN DATALENGTH(text) 
							ELSE 
								(@stmt_end - @stmt_start) 
    						END
					) 
   			FROM ::fn_get_sql(@sql_handle)
  		)
 
		RAISERROR(@line, 0, 1) WITH NOWAIT
 
		IF @NoLoop = 1
		BEGIN
			RETURN 0
		END
 
		WAITFOR DELAY @wait_str
 
	END
 
END

GO