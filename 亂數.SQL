select count(1)
from  crmbasisdb.odsdba.cb_pcust TABLESAMPLE  (5 percent)
REPEATABLE (20)