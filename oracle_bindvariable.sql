	EXEC ('SELECT * FROM (
	          SELECT B.TX_CATEGORY,
                       B.PAYMENT_METHOD,
                       B.APPLY_TYPE,
                       B.TX_DATE,
                       B.TX_AMOUNT,
                       B.TX_BALANCE,
                       C.STORE_ID,
                       C.STORE_NAME,
                       C.POS_MACHINE_ID,
                       B.BS_DATE,
                       C.POS_TX_ID
				FROM BMS_VT_TRANS_DETAIL B
				LEFT OUTER JOIN BMS_VT_VALUE_ADDED C ON B.TX_ID = C.TX_ID
				WHERE B.VTP_ACCT_ID = ? AND B.TX_DATE BETWEEN  ? AND ?
				ORDER BY B.BS_DATE DESC, B.TX_DATE DESC)
			WHERE ROWNUM<101',@ACCT_ID,@START_TIME,@END_TIME) AT [ETCDB]