CREATE OR REPLACE VIEW v_latest_bp_contract AS
select c.id
     , c.created_date
     , c.updated_date
     , c.is_deleted
     , c.deleted_date
     , c.start_date
     , c.end_date
     , c.is_hourly_pay
     , c.is_fixed_cost
     , c.is_show_formula
     , c.allowance_base
     , c.allowance_base_memo
     , c.allowance_time_min
     , c.allowance_time_max
     , c.allowance_time_memo
     , c.allowance_overtime
     , c.allowance_overtime_memo
     , c.allowance_absenteeism
     , c.allowance_absenteeism_memo
     , c.allowance_other
     , c.allowance_other_memo
     , c.member_id
     , c.member_type
     , c.contract_type
     , c.company_id
     , c.business_days
     , c.calculate_time_min
     , c.calculate_time_max
     , c.calculate_type
     , c.status
     , c.comment
     , IF(c.end_date is not null and c.end_date < current_date(), 1, 0) as is_retired 
     , pm.id as projectmember_id
     , p.id as project_id
     , msp1.salesperson_id as salesperson_id
     , bpmo1.id as current_bp_order_id
     , bpmo2.id as next_bp_order_id
     , null as lump_order_id
  from eb_bp_contract c 
  left join eb_projectmember pm on pm.member_id = c.member_id and pm.start_date <= current_date() and pm.end_date >= current_date() and pm.is_deleted = 0 and pm.status = 2
  left join eb_project p on p.id = pm.project_id and p.is_deleted = 0
  left join eb_membersalespersonperiod msp1 on msp1.member_id = c.member_id 
                                           and msp1.is_deleted = 0 
                                           and msp1.start_date <= current_date() 
                                           and (msp1.end_date >= current_date() or msp1.end_date is null)
  left join eb_bpmemberorder bpmo1 on bpmo1.project_member_id = pm.id 
                                  and concat(bpmo1.year, bpmo1.month) <= date_format(current_date(), '%Y%m') 
                                  and concat(bpmo1.end_year, bpmo1.end_month) >= date_format(current_date(), '%Y%m')
  left join eb_bpmemberorder bpmo2 on bpmo2.project_member_id = pm.id 
                                  and concat(bpmo2.year, bpmo2.month) <= date_format(date_add(current_date(), interval 1 month), '%Y%m') 
                                  and concat(bpmo2.end_year, bpmo2.end_month) >= date_format(date_add(current_date(), interval 1 month), '%Y%m')

 where c.status <> '04'
   and c.start_date = (
           select max(start_date)
             from eb_bp_contract s1
			where s1.member_id = c.member_id
              and s1.status <> '04'
       )
UNION ALL
select c.id
     , c.created_date
     , c.updated_date
     , c.is_deleted
     , c.deleted_date
     , c.start_date
     , c.end_date
     , 0 as is_hourly_pay
     , 1 as is_fixed_cost
     , 0 as is_show_formula
     , c.allowance_base
     , null as allowance_base_memo
     , 0 as allowance_time_min
     , 0 as allowance_time_max
     , null as allowance_time_memo
     , 0 as allowance_overtime
     , null as allowance_overtime_memo
     , 0 as allowance_absenteeism
     , null as allowance_absenteeism_memo
     , 0 as allowance_other
     , null as allowance_other_memo
     , null as member_id
     , null as member_type
     , c.contract_type
     , c.company_id
     , null as business_days
     , null as calculate_time_min
     , null as calculate_time_max
     , null as calculate_type
     , c.status
     , c.comment
     , 0 as is_retired 
     , null as projectmember_id
     , p.id as project_id
     , null as salesperson_id
     , null as current_bp_order_id
     , null as next_bp_order_id
     , bplo.id as lump_order_id
  from eb_bp_lump_contract c
  left join eb_project p on p.id = c.project_id
  left join eb_bplumporder bplo on bplo.contract_id = c.id