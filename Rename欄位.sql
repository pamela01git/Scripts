exec sp_rename 'cb_dt.[LMNEDYS]','LMNDYS','column'

A. 重新命名資料表
本範例將 customers 資料表重新命名為 custs。

EXEC sp_rename 'customers', 'custs'

B. 重新命名資料行
本範例將 customers 資料表中的 contact title 資料行重新命名為 title。

EXEC sp_rename 'customers.[contact title]', 'title', 'COLUMN'
