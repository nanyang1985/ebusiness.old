CREATE OR REPLACE VIEW v_release_list AS
select null as id
     , m.id as member_id
     , concat(m.first_name, ' ', m.last_name) as member_name
     , pm.start_date
     , pm.end_date
     , date_format(pm.end_date, '%Y%m') as release_ym
     , msp1.division_id
	 , (select s1.name from eb_section s1 where s1.id = msp1.division_id) as division_name
     , (select s1.id from eb_section s1 where s1.id = msp1.section_id) as section_id
     , (select s1.name from eb_section s1 where s1.id = msp1.section_id) as section_name
     , (select s1.id from eb_section s1 where s1.id = msp1.subsection_id) as subsection_id
     , (select s1.name from eb_section s1 where s1.id = msp1.subsection_id) as subsection_name
     , msp2.salesperson_id
     , (select concat(s1.first_name, ' ', s1.last_name) from eb_salesperson s1 where s1.id = msp2.salesperson_id) as salesperson_name
     , pm.id as projectmember_id
     , p.id as project_id
     , p.name as project_name
     , c.member_type
     , case c.member_type
           when 4 then c.company_id
		   else null
	   end as subcontractor_id
  from eb_member m
  join eb_projectmember pm on m.id = pm.member_id
  join eb_project p on p.id = pm.project_id
  left join eb_membersectionperiod msp1 on msp1.member_id = m.id 
                                       and msp1.is_deleted = 0 
                                       and msp1.start_date <= current_date()
                                       and (msp1.end_date >= current_date() or msp1.end_date is null)
  left join eb_membersalespersonperiod msp2 on msp2.member_id = m.id 
                                           and msp2.is_deleted = 0 
                                           and msp2.start_date <= current_date()
                                           and (msp2.end_date >= current_date() or msp2.end_date is null)
  left join v_contract c on c.member_id = m.id 
                        and c.is_old = 0 
                        and c.status <> '04'
                        and c.start_date <= current_date()
                        and (c.end_date >= current_date() or c.end_date is null)
 where m.is_deleted = 0
   and m.is_retired = 0
   and pm.is_deleted = 0
   and pm.status = 2
   and p.is_deleted = 0
   and p.is_reserve = 0
   and pm.end_date > LAST_DAY(date_add(current_date(), interval -1 month))
   and pm.end_date <= LAST_DAY(date_add(current_date(), interval 2 month))
   and not exists (
           select 1
             from eb_projectmember s1 
			where s1.member_id = m.id
              and s1.is_deleted = 0
              and s1.status = 2
              and s1.start_date between pm.end_date and date_add(pm.end_date, interval 1 month)
       )
 order by m.first_name, m.last_name