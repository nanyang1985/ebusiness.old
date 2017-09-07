select dates.ym
	 , m.id as member_id, concat(m.first_name, ' ', m.last_name) as name
     , msp1.division_id
     , msp1.section_id
     , msp1.subsection_id
     , msp2.salesperson_id
     , c.member_type
     , pm.id as projectmember_id
     , ma.id as memberattendance_id
     , p.id as project_id
     , c1.id as client_id
  from (select distinct DATE_FORMAT(selected_date, '%Y%m') as ym from 
		(select adddate('2010-01-01', INTERVAL t2.i*20 + t1.i*10 + t0.i MONTH) selected_date from
		 (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t0,
		 (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t1,
		 (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t2) v
		where selected_date between (select min(STR_TO_DATE(concat(ma1.year, ma1.month, '01'), '%Y%m%d')) from eb_memberattendance ma1) 
								and (select max(STR_TO_DATE(concat(ma1.year, ma1.month, '01'), '%Y%m%d')) from eb_memberattendance ma1)
	   ) as dates
  join eb_member m
  join eb_projectmember pm on pm.member_id = m.id and pm.is_deleted = 0 
						  and pm.status = 2 
						  and extract(year_month from(pm.start_date)) <= dates.ym
						  and (extract(year_month from(pm.end_date)) >= dates.ym or pm.end_date is null)
  join eb_project p on p.id = pm.project_id
  join eb_client c1 on c1.id = p.client_id
  left join eb_membersectionperiod msp1 on msp1.member_id = m.id 
									   and msp1.is_deleted = 0 
									   and extract(year_month from(msp1.start_date)) <= dates.ym
									   and (extract(year_month from(msp1.end_date)) >= dates.ym or msp1.end_date is null)
  left join eb_membersalespersonperiod msp2 on msp2.member_id = m.id 
									       and msp2.is_deleted = 0 
									       and extract(year_month from(msp2.start_date)) <= dates.ym
									       and (extract(year_month from(msp2.end_date)) >= dates.ym or msp2.end_date is null)
  left join eb_memberattendance ma on ma.project_member_id = pm.id and concat(ma.year, ma.month) = dates.ym
  left join v_contract c on c.member_id = m.id 
						and c.is_old = 0 and extract(year_month from(c.start_date)) <= dates.ym
						and (extract(year_month from(c.end_date)) >= dates.ym or c.end_date is null)
 where ym = '201708'
   and msp1.subsection_id = 31