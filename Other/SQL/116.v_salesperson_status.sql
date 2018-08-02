CREATE OR REPLACE VIEW v_salesperson_status AS
select null as id
     , s.id as salesperson_id
     , concat(s.first_name, ' ', s.last_name) as salesperson_name
     , count(m.id) as all_member_count
     , sum(IF(msp3.id is not null, 1, 0)) as sales_off_count
     , sum(IF(pm.id is not null and p.is_reserve = 0, 1, 0)) as working_member_count
     , sum(IF(pm.id is null and msp3.id is null, 1, 0)) as waiting_member_count
     , sum(IF(r.release_ym = date_format(current_date(), '%Y%m'), 1, 0)) as release_count
     , sum(IF(r.release_ym = date_format(date_add(current_date(), interval 1 month), '%Y%m'), 1, 0)) as release_next_count
     , sum(IF(r.release_ym = date_format(date_add(current_date(), interval 2 month), '%Y%m'), 1, 0)) as release_next2_count
  from eb_salesperson s
  join eb_membersalespersonperiod msp1 on msp1.salesperson_id = s.id 
                                      and msp1.is_deleted = 0
                                      and msp1.start_date <= current_date()
                                      and (msp1.end_date >= current_date() or msp1.end_date is null)
  join eb_member m on m.id = msp1.member_id and m.is_deleted = 0 and m.is_retired = 0
  left join eb_projectmember pm on pm.member_id = m.id 
                               and pm.status = 2 
                               and pm.is_deleted = 0
                               and pm.start_date <= current_date()
                               and (pm.end_date >= current_date() or pm.end_date is null)
                               and pm.id = (
                                       select max(pm1.id) 
                                         from eb_projectmember pm1 
										 where pm1.member_id = m.id
                                           and pm1.is_deleted = 0
                                           and pm1.status = 2
                                           and pm1.start_date <= current_date()
                                           and (pm1.end_date >= current_date() or pm1.end_date is null)
                                   )
  left join eb_project p on p.id = pm.project_id
                        and p.is_deleted = 0
                        and p.is_reserve = 0
  left join eb_membersalesoffperiod msp3 on msp3.member_id = m.id
                                        and msp3.is_deleted = 0
                                        and msp3.start_date <= current_date()
                                        and (msp3.end_date >= current_date() or msp3.end_date is null)
  left join v_release_list r on r.member_id = m.id and r.salesperson_id = s.id
 where s.is_deleted = 0
   and s.is_retired = 0
   and exists (
           select 1
             from eb_membersectionperiod s1
            where s1.member_id = m.id
              and s1.is_deleted = 0
       )
   and (exists (
           select 1
             from eb_contract s1
            where s1.member_id = m.id
              and s1.status <> '04'
              and s1.start_date <= current_date()
              and (IFNULL(s1.end_date2, s1.end_date) >= current_date() or IFNULL(s1.end_date2, s1.end_date) is null)
			limit 1
               ) OR
               (
           select 1
             from eb_bp_contract s1
            where s1.member_id = m.id
              and s1.status <> '04'
              and s1.start_date <= current_date()
              and (s1.end_date >= current_date() or s1.end_date is null)
			limit 1
               )
       )
 group by s.id
;