select S1.age_cd 
from ( select age_Cd  from  cn_age_cd) as S1
        ,(select age_Cd  from  cn_age_cd
          where age_cd < 50) As S2
where S1.age_cd=S2.age_Cd