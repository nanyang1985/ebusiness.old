CREATE OR REPLACE VIEW v_organization_turnover AS
select m.id as member_id
     , m.employee_id
     , concat(m.first_name, ' ', m.last_name) as member_name
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
     , msp2.salesperson_id
	 , (select concat(s1.first_name, ' ', s1.last_name) from eb_salesperson s1 where s1.id = msp2.salesperson_id) as salesperson_name
	 , pm.id as projectmember_id
	 , p.id as project_id
	 , p.name as project_name
	 , p.is_reserve
	 , p.is_lump
	 , c1.id as client_id
	 , c1.name as client_name
     , c.company_id
	 , case c.content_type_id
		   when 7 then (select name from eb_company where id = c.company_id)
		   else (select name from eb_subcontractor where id = c.company_id)
	   end as company_name
	 , c.member_type
     , c.is_loan
     , pr.id as projectrequest_id
     , prd.id as projectrequestdetail_id
	 , IFNULL(IF(c.is_hourly_pay = 0, c.cost, c.cost * get_attendance_total_hours(IF(ma.total_hours_bp is null or ma.total_hours_bp = 0, IFNULL(ma.total_hours, 0), ma.total_hours_bp)) + c.allowance_other), 0) as salary
	 , IFNULL(ma.allowance, 0) as allowance
	 , get_night_allowance(ma.night_days) as night_allowance
	 , get_overtime_cost(IF(ma.total_hours_bp is null or ma.total_hours_bp = 0, IFNULL(ma.total_hours, 0), ma.total_hours_bp), get_min_hours(c.member_type, c.calculate_type, get_days(), c.allowance_time_min), c.allowance_time_max, c.is_hourly_pay, c.is_fixed_cost, p.is_reserve, c.allowance_absenteeism, c.allowance_overtime) as overtime_cost
	 , IFNULL(ma.traffic_cost, 0) as traffic_cost
     , case c.member_type
           when 4 then get_bp_expenses(pm.id, ma.year, ma.month)
           else IFNULL(ma.expenses, 0) 
	   end as expenses
	 , get_employment_insurance(
		   c.member_type,
		   IFNULL(IF(c.is_hourly_pay = 0, c.cost, c.cost * get_attendance_total_hours(IF(ma.total_hours_bp is null or ma.total_hours_bp = 0, IFNULL(ma.total_hours, 0), ma.total_hours_bp))), 0),
		   IFNULL(ma.allowance, 0),
		   get_night_allowance(ma.night_days),
		   get_overtime_cost(IF(ma.total_hours_bp is null or ma.total_hours_bp = 0, IFNULL(ma.total_hours, 0), ma.total_hours_bp), get_min_hours(c.member_type, c.calculate_type, get_days(), c.allowance_time_min), c.allowance_time_max, c.is_hourly_pay, c.is_fixed_cost, p.is_reserve, c.allowance_absenteeism, c.allowance_overtime),
		   IFNULL(ma.traffic_cost, 0)
	   ) as employment_insurance
	 , get_health_insurance(
		   c.endowment_insurance,
		   IFNULL(IF(c.is_hourly_pay = 0, c.cost, c.cost * get_attendance_total_hours(IF(ma.total_hours_bp is null or ma.total_hours_bp = 0, IFNULL(ma.total_hours, 0), ma.total_hours_bp))), 0),
		   IFNULL(ma.allowance, 0),
		   get_night_allowance(ma.night_days),
		   get_overtime_cost(IF(ma.total_hours_bp is null or ma.total_hours_bp = 0, IFNULL(ma.total_hours, 0), ma.total_hours_bp), get_min_hours(c.member_type, c.calculate_type, get_days(), c.allowance_time_min), c.allowance_time_max, c.is_hourly_pay, c.is_fixed_cost, p.is_reserve, c.allowance_absenteeism, c.allowance_overtime),
		   IFNULL(ma.traffic_cost, 0),
           m.id,
           concat(pr.year, pr.month)
	   ) as health_insurance 
	 , prd.total_price
     , prd.expenses_price
     , case prd.id
           when (select max(s1.id) from eb_projectrequestdetail s1 where s1.project_request_id = pr.id) 
               then (pr.tax_amount - IFNULL((select sum(truncate(IFNULL(prh.tax_rate, 0) * s2.total_price, 0)) from eb_projectrequestdetail s2 where s2.project_request_id = pr.id and s2.id <> prd.id), 0))
           else truncate(IFNULL(prh.tax_rate, 0) * prd.total_price, 0)
	   end as tax_price
  from eb_projectrequestdetail prd		/* １つの案件に複数の請求書が存在する場合があるので、eb_projectrequestdetailをメインとしてデータを取得されている。要員のアサインした一括案件は下のUNION部分から取得する */
  join eb_projectrequest pr on pr.id = prd.project_request_id
  join eb_projectrequestheading prh on prh.project_request_id = pr.id
  join eb_projectmember pm on pm.id = prd.project_member_id
  left join eb_memberattendance ma on ma.project_member_id = pm.id and ma.year = pr.year and ma.month = pr.month
  join eb_member m on m.id = pm.member_id
  join eb_project p on p.id = pm.project_id
  join eb_client c1 on c1.id = p.client_id
  left join eb_membersectionperiod msp1 on msp1.member_id = m.id 
									   and msp1.is_deleted = 0 
									   and extract(year_month from(msp1.start_date)) <= concat(pr.year, pr.month)
									   and (extract(year_month from(msp1.end_date)) >= concat(pr.year, pr.month) or msp1.end_date is null)
  left join eb_membersalespersonperiod msp2 on msp2.member_id = m.id 
									       and msp2.is_deleted = 0 
									       and extract(year_month from(msp2.start_date)) <= concat(pr.year, pr.month)
									       and (extract(year_month from(msp2.end_date)) >= concat(pr.year, pr.month) or msp2.end_date is null)
  left join v_contract c on c.member_id = m.id 
						and c.is_old = 0 
                        and extract(year_month from(c.start_date)) <= concat(pr.year, pr.month)
						and (extract(year_month from(c.end_date)) >= concat(pr.year, pr.month) or c.end_date is null)
 where concat(pr.year, pr.month) = get_ym()
UNION ALL
select null as member_id
     , null as employee_id
     , null as member_name
	 , s1.id as division_id
	 , s1.name division_name
	 , null as section_id
	 , null as section_name
	 , null as subsection_id
	 , null as subsection_name
     , s2.id as salesperson_id
	 , concat(s2.first_name, ' ' , s2.last_name) as salesperson_name
	 , null as projectmember_id
	 , p.id as project_id
	 , p.name as project_name
	 , p.is_reserve
	 , p.is_lump
	 , c1.id as client_id
	 , c1.name as client_name
     , null as company_id
	 , null as company_name
	 , null as member_type
     , 0 as is_loan
     , pr.id as projectrequest_id
     , prd.id as projectrequestdetail_id
	 , 0 as salary
	 , 0 as allowance
	 , 0 as night_allowance
	 , 0 as overtime_cost
	 , 0 as traffic_cost
	 , 0 as expenses
	 , 0 as employment_insurance
	 , 0 as health_insurance 
	 , pr.turnover_amount as total_price
     , pr.expenses_amount as expenses_price
     , pr.tax_amount as tax_price
  from eb_projectrequest pr
  left join eb_projectrequestdetail prd on pr.id = prd.project_request_id
  join eb_projectrequestheading prh on prh.project_request_id = pr.id
  join eb_project p on p.id = pr.project_id
  join eb_client c1 on c1.id = p.client_id
  left join eb_section s1 on s1.id = p.department_id
  left join eb_salesperson s2 on s2.id = p.salesperson_id
 where concat(pr.year, pr.month) = get_ym()
   and prd.id is null
