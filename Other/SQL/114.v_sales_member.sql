/* 作業社員の一覧の取得する
 * 管理部、営業部などの社員を除外する。
 * 
 * 出向の社員が存在する場合、重複出る可能性があります。
 */

CREATE OR REPLACE VIEW v_sales_member AS
select m.id as member_id
     , m.employee_id
     , concat(m.first_name, ' ', m.last_name) as member_name
     , msp1.division_id
     , (select s1.name from eb_section s1 where s1.id = msp1.division_id) as division_name
     , msp1.section_id
     , (select s1.name from eb_section s1 where s1.id = msp1.section_id) as section_name
     , msp1.subsection_id
     , (select s1.name from eb_section s1 where s1.id = msp1.subsection_id) as subsection_name
     , c.id as contract_id
     , c.is_loan
     , c.content_type_id
     , IF(c.content_type_id = 8, c.company_id, null) as subcontactor_id
     , IF(c.content_type_id = 8, (select s1.name from eb_subcontractor s1 where s1.id = c.company_id), null) as subcontractor_name
     , msp2.salesperson_id
     , (select concat(s1.first_name, ' ', s1.last_name) from eb_salesperson s1 where s1.id = msp2.salesperson_id) as salesperson_name
     , get_member_status_by_month(m.id, sr.id, get_ym()) as status_month
     , get_member_status_today(m.id, sr.id) as status_today
     , get_member_release_date(m.id) as release_date
     , IF(c.id is null or m.is_retired = 1, 1, 0) as is_retired
     , IF(sr.id is null, 0, 1) as is_sales_off
     , sr.id as salesofreason_id
     , sr.name as salesofreason_name
  from eb_member m
  left join eb_membersectionperiod msp1 on msp1.member_id = m.id 
                                       and msp1.is_deleted = 0 
                                       and  extract(year_month from(msp1.start_date)) <= get_ym()
                                       and (extract(year_month from(msp1.end_date)) >= get_ym() or msp1.end_date is null)
  left join v_contract c on c.member_id = m.id 
                        and c.is_old = 0 and c.status <> '04'
                        and extract(year_month from(c.start_date)) <= get_ym()
                        and (extract(year_month from(c.end_date)) >= get_ym() or c.end_date is null)
  left join eb_membersalespersonperiod msp2 on msp2.member_id = m.id 
                                           and msp2.is_deleted = 0 
                                           and extract(year_month from(msp2.start_date)) <= get_ym()
                                           and (extract(year_month from(msp2.end_date)) >= get_ym() or msp2.end_date is null)
  left join eb_membersalesoffperiod msp3 on msp3.member_id = m.id
                                        and msp3.is_deleted = 0
                                        and extract(year_month from(msp3.start_date)) <= get_ym()
                                        and (extract(year_month from(msp3.end_date)) >= get_ym() or msp3.end_date is null)
  left join mst_salesofreason sr on sr.id = msp3.sales_off_reason_id
 where m.is_deleted = 0
   and exists (select 1 from eb_membersectionperiod s1 where s1.member_id = m.id and s1.is_deleted = 0)
 order by m.employee_id
;