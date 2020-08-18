Be aware that ISNUMERIC() allows several different numeric formats so considers these strings all "numeric":

SELECT ISNUMERIC('4D0'),
 ISNUMERIC('5E3'),
 ISNUMERIC('.'),
 ISNUMERIC(','),
 ISNUMERIC(',.'), --!
 ISNUMERIC('$1')

If you want to make sure only digits (0 thru 9) are in a column, the safest way is this:

SELECT *
FROM ...
WHERE PATINDEX('%[^0-9]%', LTRIM(yourColumn)) = 0

--remember, non-zero value means it's "bad" data, zero means "good"
SELECT PATINDEX('%[^0-9]%', '4D0'),
 PATINDEX('%[^0-9]%', '5E3'),
 PATINDEX('%[^0-9]%', '.'),
 PATINDEX('%[^0-9]%', ','),
 PATINDEX('%[^0-9]%', ',.'),
 PATINDEX('%[^0-9]%', '$1'),
 PATINDEX('%[^0-9]%', '0123456789') 

elect PATINDEX('%[^0-9.]%', '110.3424') 