CREATE OR REPLACE VIEW v_status_monthly AS
select d.ym as ym
     , d.year
     , d.month
     , count(m.id) as all_member_count
     , (count(m.id) - sum(IF(msp3.id is not null, 1, 0))) as sales_on_count
     , sum(IF(msp3.id is not null, 1, 0)) as sales_off_count
     , sum(IF(pm.id is not null and p.is_reserve = 0, 1, 0)) as working_member_count
     , sum(IF(pm.id is null and msp3.id is null, 1, 0)) as waiting_member_count 
     , sum(IF(c.id is not null, 1, 0)) as bp_member_count
     , (sum(IF(c.id is not null, 1, 0)) - sum(IF(c.id is not null and msp3.id is not null, 1, 0))) as bp_sales_on_count
     , sum(IF(c.id is not null and pm.id is not null and p.is_reserve = 0, 1, 0)) as bp_working_member_count
     , sum(IF(c.id is not null and pm.id is null and msp3.id is null, 1, 0)) as bp_waiting_member_count
     , sum(IF(c.id is not null and msp3.id is not null, 1, 0)) as bp_sales_off_count
  from v_turnover_dates d
  join eb_member m
  left join eb_membersalespersonperiod msp1 on msp1.member_id = m.id 
                                           and msp1.is_deleted = 0
                                           and extract(year_month from msp1.start_date) <= d.ym
                                           and (extract(year_month from (msp1.end_date)) >= d.ym or msp1.end_date is null)
  left join eb_salesperson s on s.id = msp1.salesperson_id
  left join eb_projectmember pm on pm.member_id = m.id 
                               and pm.status = 2 
                               and pm.is_deleted = 0
                               and extract(year_month from pm.start_date) <= d.ym
                               and (extract(year_month from (pm.end_date)) >= d.ym or pm.end_date is null)
                               and pm.id = (
                                       select max(pm1.id) 
                                         from eb_projectmember pm1 
										 where pm1.member_id = m.id
                                           and pm1.is_deleted = 0
                                           and pm1.status = 2
                                           and extract(year_month from pm1.start_date) <= d.ym
                                           and (extract(year_month from (pm1.end_date)) >= d.ym or pm1.end_date is null)
                                   )
  left join eb_project p on p.id = pm.project_id
                        and p.is_deleted = 0
                        and p.is_reserve = 0
  left join eb_membersalesoffperiod msp3 on msp3.member_id = m.id
                                        and msp3.is_deleted = 0
                                        and extract(year_month from msp3.start_date) <= d.ym
                                        and (extract(year_month from (msp3.end_date)) >= d.ym or msp3.end_date is null)
  left join eb_bp_contract c on c.member_id = m.id
                            and c.status <> '04'
                            and extract(year_month from c.start_date) <= d.ym
                            and (extract(year_month from (c.end_date)) >= d.ym or c.end_date is null)
 where m.is_deleted = 0
   and m.is_retired = 0
   and exists (
           select 1
             from eb_membersectionperiod s1
            where s1.member_id = m.id
              and s1.is_deleted = 0
			limit 1
       )
   and (exists (
           select 1
             from eb_contract s1
            where s1.member_id = m.id
              and s1.status <> '04'
              and extract(year_month from s1.start_date) <= d.ym
              and (IFNULL(extract(year_month from (s1.end_date2)), extract(year_month from (s1.end_date))) >= d.ym or IFNULL(s1.end_date2, s1.end_date) is null)
			limit 1
               ) OR
               (
           select 1
             from eb_bp_contract s1
            where s1.member_id = m.id
              and s1.status <> '04'
              and extract(year_month from s1.start_date) <= d.ym
              and (extract(year_month from (s1.end_date)) >= d.ym or s1.end_date is null)
			limit 1
               )
       )
 group by d.ym
;