USE [Cognos841Log]
GO

/****** Object:  UserDefinedFunction [dbo].[Fn_Ora_Instr]    Script Date: 8/29/2012 9:28:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[Fn_Ora_Instr]
	(@str2 varchar(8000), @str1 varchar(1000), @start int, @Occurs int)
RETURNS int
AS
BEGIN
	DECLARE @Found int, @LastPosition int
	SET @Found = 0
	SET @LastPosition = @start - 1

	WHILE (@Found < @Occurs)
	BEGIN
		IF (CHARINDEX(@str1, @str2, @LastPosition + 1) = 0)
			BREAK
		  ELSE
			BEGIN
				SET @LastPosition = CHARINDEX(@str1, @str2, @LastPosition + 1)
				SET @Found = @Found + 1
			END
	END

	RETURN @LastPosition
END

GO


