DECLARE @stillgoing bit
SET @stillgoing = 1

SET ROWCOUNT 1000000

WHILE @stillgoing = 1
BEGIN
      DELETE  BMS_PRO_GANTRY_tX
            WHERE TRANSACTION_ID between 1310010000000000000 and 1310020000000000000 

  IF @@ROWCOUNT = 0
      SET @stillgoing = 0

  CHECKPOINT /* Will encourage the log to clear if it's in Simple recovery model */
END