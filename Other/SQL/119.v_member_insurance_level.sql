CREATE OR REPLACE VIEW v_member_insurance_level AS
select m.id as id
     , m.id as member_id
     , concat(m.first_name, ' ', m.last_name) as name
     , c.id as contract_id
     , mil.id as member_insurance_level_id
     , mil.salary
  from eb_member m
  join eb_contract c on c.member_id = m.id 
                    and c.is_deleted = 0 
                    and c.status <> '04' 
                    and c.endowment_insurance = '1'
                    and c.start_date <= current_date()
                    and (IFNULL(c.end_date, c.end_date2) is null or IFNULL(c.end_date, c.end_date2) >= current_date())
                    and c.contract_no = (select max(c1.contract_no) from eb_contract c1 where c1.start_date = c.start_date and c1.member_id = c.member_id and c1.is_deleted = 0 and c1.status <> '04')
  left join eb_member_insurance_level mil on mil.member_id = m.id 
                                         and mil.start_date <= current_date()
                                         and (mil.end_date >= current_date() or mil.end_date is null)
 order by m.id_from_api
