CREATE OR REPLACE VIEW v_member_insurance AS
select d.ym
     , d.year
     , d.month
     , mil.member_id
     , concat(m.first_name, ' ', m.last_name) as name
     , m.birthday
     , TIMESTAMPDIFF(YEAR, m.birthday, STR_TO_DATE(concat(d.year, d.month, '01'), '%Y%m%d')) as age
     , mil.salary
     , ilp.rate1
     , ilp.rate2
     , ilp.rate3
     , ild.amount1_half
     , case
           when TIMESTAMPDIFF(YEAR, m.birthday, STR_TO_DATE(concat(d.year, d.month, '01'), '%Y%m%d')) >= 40 then
               ild.amount2_half + IFNULL(ild.amount3_half
                    , IF(mil.salary > (select max(salary) from eb_insurance_level_detail s1 where s1.period_id = ilp.id and s1.level2 is not null), 
				          (select max(amount3_half) from eb_insurance_level_detail s1 where s1.period_id = ilp.id)
                        , (select min(amount3_half) from eb_insurance_level_detail s1 where s1.period_id = ilp.id)
                      )
		        )
		   else ild.amount1_half + IFNULL(ild.amount3_half
                    , IF(mil.salary > (select max(salary) from eb_insurance_level_detail s1 where s1.period_id = ilp.id and s1.level2 is not null), 
				          (select max(amount3_half) from eb_insurance_level_detail s1 where s1.period_id = ilp.id)
                        , (select min(amount3_half) from eb_insurance_level_detail s1 where s1.period_id = ilp.id)
                      )
		        )
	   end as health_insurance
  from v_turnover_dates d
  join eb_member_insurance_level mil on extract(year_month from mil.start_date) <= d.ym and (extract(year_month from mil.end_date) >= d.ym or mil.end_date is null)
  join eb_insurance_level_period ilp on extract(year_month from ilp.start_date) <= d.ym and (extract(year_month from ilp.end_date) >= d.ym or ilp.end_date is null)
  join eb_insurance_level_detail ild on ild.period_id = ilp.id and ild.salary = mil.salary
  join eb_member m on m.id = mil.member_id
  