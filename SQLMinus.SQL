select age_cd
from (
select age_Cd  from  cn_age_cd
union all
(select age_Cd  from  cn_age_cd
          where age_cd < 50)) as S1
group by age_cd
having count(1)  =1