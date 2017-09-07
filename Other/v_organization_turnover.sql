CREATE OR REPLACE VIEW v_organization_turnover AS
select d.ym
     , m.id as member_id
	 , m.employee_id
	 , m.first_name
	 , m.last_name
	 , msp1.id as membersectionperiod_id
	 , case p.is_reserve
		   when 1 then p.department_id
		   else (select s1.id from eb_section s1 where s1.id = msp1.division_id) 
	   end as division_id
	 , case p.is_reserve
		   when 1 then (select s1.name from eb_section s1 where s1.id = p.department_id) 
		   else (select s1.name from eb_section s1 where s1.id = msp1.division_id) 
	   end as division_name
	 , (select s1.id from eb_section s1 where s1.id = msp1.section_id) as section_id
	 , (select s1.name from eb_section s1 where s1.id = msp1.section_id) as section_name
	 , (select s1.id from eb_section s1 where s1.id = msp1.subsection_id) as subsection_id
	 , (select s1.name from eb_section s1 where s1.id = msp1.subsection_id) as subsection_name
	 , pm.id as projectmember_id
	 , p.id as project_id
	 , p.name as project_name
	 , p.is_reserve
	 , p.is_lump
	 , c1.id as client_id
	 , c1.name as client_name
	 , case c.content_type_id
		   when 7 then (select name from eb_company where id = c.company_id)
		   else (select name from eb_subcontractor where id = c.company_id)
	   end as company_name
	 , c.endowment_insurance
	 , c.member_type
	 , case c.member_type
		   when 1 then '正社員'
		   when 2 then '契約社員'
		   when 3 then '個人事業者'
		   when 4 then '他社技術者'
		   when 5 then 'パート'
		   when 6 then 'アルバイト'
		   when 7 then '正社員（試用期間）'
		   else c.member_type
	   end as member_type_name
	 , c.is_loan
	 , IF(p.is_lump = 1 and prd.id is null, (select min(t1.id) from eb_projectrequest t1 where t1.project_id = p.id and concat(t1.year, t1.month) = d.ym), IFNULL(prd.id, 0)) as projectrequestdetail_id
	 , IF(ma.id is null, IFNULL(prev_ma.traffic_cost, 0), 0) as prev_traffic_cost			-- 先月の勤務交通費
	 , IF(ma.id is null, IFNULL(prev_ma.allowance, 0), 0) as prev_allowance					-- 先月の手当
	 , ma.id as memberattendance_id
	 , IFNULL(ma.total_hours, 0) as total_hours
	 , IFNULL(ma.total_days, 0) as total_days
	 , IFNULL(ma.night_days, 0) as night_days
	 , IFNULL(ma.advances_paid_client, 0) as advances_paid_client
	 , IFNULL(ma.advances_paid, 0) as advances_paid
	 , IFNULL(ma.traffic_cost, 0) as traffic_cost
	 , case 
		   when p.is_lump = 1 and prd.id is null then (select t1.amount from eb_projectrequest t1 where t1.project_id = p.id and concat(t1.year, t1.month) = d.ym)
		   else IFNULL(prd.total_price + prd.expenses_price + prd.total_price * prh.tax_rate, 0) 
	   end as all_price
	 , case
		   when p.is_lump = 1 and prd.id is null then (select t1.turnover_amount from eb_projectrequest t1 where t1.project_id = p.id and concat(t1.year, t1.month) = d.ym)
		   else IFNULL(prd.total_price, 0) 
	   end as total_price
	 , case
		   when p.is_lump = 1 and prd.id is null then (select t1.expenses_amount from eb_projectrequest t1 where t1.project_id = p.id and concat(t1.year, t1.month) = d.ym)
		   else IFNULL(prd.expenses_price, 0) 
	   end as expenses_price
	 , IFNULL(IF(c.is_hourly_pay = 0, c.cost, c.cost * get_attendance_total_hours(ma.total_hours)), 0) as salary
	 , IFNULL(ma.allowance, 0) as allowance
	 , get_night_allowance(ma.night_days) as night_allowance
	 , get_overtime_cost(ma.total_hours, c.allowance_time_min, c.allowance_time_max, c.is_hourly_pay, c.is_fixed_cost, p.is_reserve, c.allowance_absenteeism, c.allowance_overtime) as overtime_cost
	 , IFNULL(ma.expenses, 0) as expenses
	 , get_employment_insurance(
		   c.member_type,
		   IFNULL(IF(c.is_hourly_pay = 0, c.cost, c.cost * get_attendance_total_hours(ma.total_hours)), 0),
		   IFNULL(ma.allowance, 0),
		   get_night_allowance(ma.night_days),
		   get_overtime_cost(ma.total_hours, c.allowance_time_min, c.allowance_time_max, c.is_hourly_pay, c.is_fixed_cost, p.is_reserve, c.allowance_absenteeism, c.allowance_overtime),
		   IFNULL(ma.traffic_cost, 0)
	   ) as employment_insurance
	 , get_health_insurance(
		   c.endowment_insurance,
		   IFNULL(IF(c.is_hourly_pay = 0, c.cost, c.cost * get_attendance_total_hours(ma.total_hours)), 0),
		   IFNULL(ma.allowance, 0),
		   get_night_allowance(ma.night_days),
		   get_overtime_cost(ma.total_hours, c.allowance_time_min, c.allowance_time_max, c.is_hourly_pay, c.is_fixed_cost, p.is_reserve, c.allowance_absenteeism, c.allowance_overtime),
		   IFNULL(ma.traffic_cost, 0)
	   ) as health_insurance 
  from (select distinct DATE_FORMAT(selected_date, '%Y%m') as ym from 
		(select adddate('2010-01-01', INTERVAL t2.i*20 + t1.i*10 + t0.i MONTH) selected_date from
		 (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t0,
		 (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t1,
		 (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t2) v
		where selected_date between (select min(STR_TO_DATE(concat(ma1.year, ma1.month, '01'), '%Y%m%d')) from eb_memberattendance ma1) 
								and (select max(STR_TO_DATE(concat(ma1.year, ma1.month, '01'), '%Y%m%d')) from eb_memberattendance ma1)
	   ) as d
  join eb_member m
  left join eb_membersectionperiod msp1 on msp1.member_id = m.id 
									   and msp1.is_deleted = 0 
									   and extract(year_month from(msp1.start_date)) <= d.ym
									   and (extract(year_month from(msp1.end_date)) >= d.ym or msp1.end_date is null)
  join eb_projectmember pm on pm.member_id = m.id and pm.is_deleted = 0 
						  and pm.status = 2 
						  and extract(year_month from(pm.start_date)) <= d.ym
						  and (extract(year_month from(pm.end_date)) >= d.ym or pm.end_date is null)
  join eb_project p on p.id = pm.project_id
  join eb_client c1 on c1.id = p.client_id
  left join eb_memberattendance ma on ma.project_member_id = pm.id and concat(ma.year, ma.month) = d.ym
  left join eb_memberattendance prev_ma on prev_ma.project_member_id = pm.id 
									   and concat(prev_ma.year, prev_ma.month) = DATE_FORMAT(STR_TO_DATE(concat(d.ym, '01'), '%Y%m%d') - INTERVAL 1 MONTH, '%Y%m')
  left join eb_projectrequestdetail prd on prd.project_member_id = pm.id and concat(prd.year, prd.month) = d.ym
  left join eb_projectrequest pr on pr.id = prd.project_request_id and concat(pr.year, pr.month) = d.ym
  left join eb_projectrequestheading prh on prh.project_request_id = pr.id
  left join v_contract c on c.member_id = m.id 
						and c.is_old = 0 and extract(year_month from(c.start_date)) <= d.ym
						and (extract(year_month from(c.end_date)) >= d.ym or c.end_date is null)
 where m.is_deleted = 0
union all
select d.ym
     , null as member_id
	 , null as employee_id
	 , null as first_name
	 , null as last_name
	 , null as membersectionperiod_id
	 , s.id as division_id
	 , s.name division_name
	 , null as section_id
	 , null as section_name
	 , null as subsection_id
	 , null as subsection_name
	 , null as projectmember_id
	 , p.id as project_id
	 , p.name as project_name
	 , p.is_reserve
	 , p.is_lump
	 , c1.id as client_id
	 , c1.name as client_name
	 , null as company_name
	 , null as endowment_insurance
	 , null as member_type
	 , null as member_type_name
	 , 0 as is_loan
	 , pr.id as projectrequestdetail_id
	 , 0 as prev_traffic_cost
	 , 0 as prev_allowance
	 , null as memberattendance_id
	 , 0 as total_hours
	 , 0 as total_days
	 , 0 as night_days
	 , 0 as advances_paid_client
	 , 0 as advances_paid
	 , 0 as traffic_cost
	 , pr.amount as all_price
	 , pr.turnover_amount as total_price
	 , pr.expenses_amount as expenses_price
	 , 0 as salary
	 , 0 as allowance
	 , 0 as night_allowance
	 , 0 as overtime_cost
	 , 0 as expenses
	 , 0 as employment_insurance
	 , 0 as health_insurance 
  from (select distinct DATE_FORMAT(selected_date, '%Y%m') as ym from 
		(select adddate('2010-01-01', INTERVAL t2.i*20 + t1.i*10 + t0.i MONTH) selected_date from
		 (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t0,
		 (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t1,
		 (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t2) v
		where selected_date between (select min(STR_TO_DATE(concat(ma1.year, ma1.month, '01'), '%Y%m%d')) from eb_memberattendance ma1) 
								and (select max(STR_TO_DATE(concat(ma1.year, ma1.month, '01'), '%Y%m%d')) from eb_memberattendance ma1)
	   ) as d
  join eb_project p
  join eb_section s on p.department_id = s.id
  join eb_client c1 on c1.id = p.client_id
  join eb_projectrequest pr on pr.project_id = p.id
 where p.is_lump = 1
   and p.is_deleted = 0
   and concat(pr.year, pr.month) = d.ym
   and not exists(select 1 from eb_projectmember pm where pm.project_id = p.id and pm.is_deleted = 0)
