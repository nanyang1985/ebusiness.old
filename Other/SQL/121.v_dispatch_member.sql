CREATE OR REPLACE VIEW v_dispatch_member AS
select m.id as member_id
     , concat(m.first_name, ' ', m.last_name) as member_name
     , pm.id as projectmember_id
     , case
           when pm.start_date > STR_TO_DATE(concat(get_ym(), '01'), '%Y%m%d') then pm.start_date
           else STR_TO_DATE(concat(get_ym(), '01'), '%Y%m%d')
       end as start_date                                                                            -- 派遣期間（開始日）
     , case
           when pm.end_date < LAST_DAY(STR_TO_DATE(concat(get_ym(), '01'), '%Y%m%d')) then pm.end_date
           else LAST_DAY(STR_TO_DATE(concat(get_ym(), '01'), '%Y%m%d'))
       end as end_date                                                                              -- 派遣期間（終了日）
     , c1.id as client_id
     , c1.name as client_name
     , c.id as contract_id
     , bp_c.id as bp_contract_id
     , case 
           when c.id is not null and c.member_type = 1 then 'WT（正社員）'
           when c.id is not null and c.member_type = 2 and c.is_loan = 0 then 'WT（契約社員）'
           when c.id is not null and c.member_type = 2 and c.is_loan = 1 then '出向'
           when bp_c.id is not null then 'BP'
           else 'Unknown'
       end as member_type_name
     , IF(c.id is not null and c.endowment_insurance = '1', '加入有', '無') as endowment_insurance  -- 社会保険加入有無
     , IFNULL(prd.basic_price, pm.price) as basic_price
     , IFNULL(prd.total_price, 0) as total_price
     , ma.total_hours
     , (get_salary(c.id, bp_c.id, ma.total_hours, ma.total_hours_bp) + IFNULL(ma.traffic_cost, 0)) as salary
     , get_ym()
  from eb_member m
  join eb_projectmember pm on pm.member_id = m.id and pm.is_deleted = 0 and pm.status = 2
  join eb_project p on p.id = pm.project_id
  join eb_client c1 on c1.id = p.client_id
  left join eb_contract c on c.member_id = m.id
                         and c.status <> '04'
                         and c.is_deleted = 0
                         and extract(year_month from c.start_date) <= get_ym()
                         and (IFNULL(extract(year_month from (c.end_date2)), extract(year_month from (c.end_date))) >= get_ym() or IFNULL(c.end_date2, c.end_date) is null)
                         and (
                             SELECT MAX(c1.contract_no)
                               FROM eb_contract c1
                              WHERE c1.start_date = c.start_date
                                AND c1.member_id = c.member_id
                                AND c1.is_deleted = 0
                                AND c1.status <> '04'
                         ) = c.contract_no
  left join eb_bp_contract bp_c on bp_c.member_id = m.id
                               and bp_c.status <> '04'
                               and bp_c.is_deleted = 0
                               and extract(year_month from bp_c.start_date) <= get_ym()
                               and (extract(year_month from (bp_c.end_date)) >= get_ym() or bp_c.end_date is null)
  left join eb_projectrequestdetail prd on prd.project_member_id = pm.id and concat(prd.year, prd.month) = get_ym()
  left join eb_memberattendance as ma on ma.project_member_id = pm.id
                                     and ma.is_deleted = 0
                                     and concat(ma.year, ma.month) = get_ym()
 where pm.contract_type = '03'
   and extract(year_month from pm.start_date) <= get_ym()
   and extract(year_month from pm.end_date) >= get_ym()
