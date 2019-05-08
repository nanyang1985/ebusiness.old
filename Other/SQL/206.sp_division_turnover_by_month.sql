delimiter //

DROP PROCEDURE IF EXISTS sp_division_turnover_by_month //

CREATE PROCEDURE sp_division_turnover_by_month(
    in_division_id integer,
    in_year char(4),
    in_month char(2)
)
BEGIN

select s.id
     , s.name
     , in_year as year
     , in_month as month
     , c.id as client_id
     , c.name as client_name
     , ifnull(sum(pm.price), 0) as total_price
     , ifnull(count(distinct pm.id), 0) as member_count
     , cast(ifnull(sum(pm.price) / count(distinct pm.id), 0) as unsigned) as average_price
  from (
select s1.id
     , s1.name
     , group_concat(distinct s2.id separator ',') as department_ids
     , group_concat(distinct s3.id separator ',') as section_ids
  from eb_section s1
  left join eb_section s2 on s2.parent_id = s1.id and s2.org_type = '02'
  left join eb_section s3 on s3.parent_id = s2.id and s3.org_type = '03'
 where s1.is_deleted = 0
   and s1.is_on_sales = 1
   and s1.org_type = '01'
 group by s1.id, s1.name
) s
  left join eb_project p on p.is_hourly_pay = 0
                        and p.is_lump = 0
                        and (s.id = p.department_id or FIND_IN_SET(p.department_id, s.department_ids) or FIND_IN_SET(p.department_id, s.section_ids))
                        and p.is_reserve = 0
  left join eb_client c on c.id = p.client_id
  left join eb_projectmember pm on pm.project_id = p.id
                               and (
								   (date_format(pm.start_date, '%Y%m') < concat(in_year, in_month) and date_format(pm.end_date, '%Y%m') > concat(in_year, in_month))
								or (date_format(pm.start_date, '%Y%m') = concat(in_year, in_month) and date_format(pm.end_date, '%Y%m') > concat(in_year, in_month) and DAY(pm.start_date) = 1)
								or (date_format(pm.start_date, '%Y%m') < concat(in_year, in_month) and date_format(pm.end_date, '%Y%m') = concat(in_year, in_month) and last_day(pm.end_date) = pm.end_date)
                                or (date_format(pm.start_date, '%Y%m') = concat(in_year, in_month) and date_format(pm.end_date, '%Y%m') = concat(in_year, in_month) and DAY(pm.start_date) = 1 and last_day(pm.end_date) = pm.end_date)
                               )
                               and ifnull(pm.hourly_pay, 0) = 0 
                               and pm.status = '2'
 where s.id = in_division_id
 group by s.id, s.name, c.id, c.name
;

END