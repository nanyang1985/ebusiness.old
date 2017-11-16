CREATE OR REPLACE VIEW v_member_without_contract AS
select m.id
	 , m.id as member_id
	 , m.employee_id
     , concat(m.first_name, ' ', m.last_name) as name
     , s.id as salesperson_id
  from eb_member m
  left join eb_membersalespersonperiod msp1 on msp1.member_id = m.id 
                                           and msp1.is_deleted = 0
                                           and msp1.start_date <= current_date()
                                           and (msp1.end_date >= current_date() or msp1.end_date is null)
  left join eb_salesperson s on s.id = msp1.salesperson_id
 where m.is_deleted = 0
   and m.is_retired = 0
   and not exists(select 1
                    from eb_contract s1
                   where s1.member_id = m.id
                     and s1.status <> '04'
                     and s1.is_deleted = 0
                 )
   and not exists(select 1
                    from eb_bp_contract s1
                   where s1.member_id = m.id
                 )
UNION
select distinct m.id
	 , m.id as member_id
	 , m.employee_id
     , concat(m.first_name, ' ', m.last_name) as name
     , s.id as salesperson_id
  from eb_member m
  join eb_projectmember pm on pm.member_id = m.id
                          and pm.start_date <= current_date()
                          and pm.end_date >= current_date()
  left join eb_membersalespersonperiod msp1 on msp1.member_id = m.id 
                                           and msp1.is_deleted = 0
                                           and msp1.start_date <= current_date()
                                           and (msp1.end_date >= current_date() or msp1.end_date is null)
  left join eb_salesperson s on s.id = msp1.salesperson_id
 where m.is_deleted = 0
   and m.is_retired = 0
   and not exists(select 1
                    from eb_contract s1
                   where s1.member_id = m.id
                     and s1.status <> '04'
                     and s1.is_deleted = 0
                     and s1.start_date <= current_date()
                     and (s1.end_date >= current_date() or s1.end_date is null)
                 )
   and not exists(select 1
                    from eb_bp_contract s1
                   where s1.member_id = m.id
                     and s1.start_date <= current_date()
                     and (s1.end_date >= current_date() or s1.end_date is null)
                 )
