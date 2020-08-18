--雖然每個campaingn的級距數不定,但只有三種情形
   --case1:point大於此級距
   --case2:point不在此級距
   --case3:point在此級距
--以此邏輯計算AO在每個級距可領之金額
--加總所有級距金額此乃它應得之獎金(newmoney)
select aoempno,campaingn,sum(newmoney)
from  (select  s1.aoempno
              ,s1.campaingn
              ,(case when s1.point > s2.end_range and s1.point > s2.start_range then (s2.end_range - s2.start_range +1 ) * s2.money -- case1:point大於此級距,金額為級距*money
                     when s1.point < s2.start_range then 0 -- case2:point小於此級距,金額為0
                     when s1.point >= s2.start_range and s1.point <= s2.end_range then (s1.point - s2.start_range - 1) * s2.money end --case3:point落於此級距,金額為point與start之間距*money
                )as newmoney
       from dbo.point s1
           ,dbo.money s2
       where s1.campaingn=s2.campaingn) a1  
group by aoempno,campaingn
