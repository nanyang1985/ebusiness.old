delimiter //

DROP PROCEDURE IF EXISTS sp_organization_turnover //

CREATE PROCEDURE sp_organization_turnover(
    in_ym char(6),
    in_days integer
)
BEGIN

select s.member_id
     , s.employee_id
     , s.member_name
     , s.division_id
     , s.division_name
     , s.section_id
     , s.section_name
     , s.subsection_id
     , s.subsection_name
     , s.salesperson_id
     , s.salesperson_name
     , s.projectmember_id
     , s.project_id
     , s.project_name
     , s.is_reserve
     , s.is_lump
     , s.client_id
     , s.client_name
     , s.company_id
     , s.company_name
     , s.member_type
     , s.is_loan
     , s.projectrequest_id
     , s.projectrequestdetail_id
     , s.salary
     , s.allowance
     , s.night_allowance
     , s.overtime_cost
     , s.traffic_cost
     , s.expenses
     , s.employment_insurance
     , s.health_insurance
     , s.total_price
     , s.expenses_price
     , s.tax_price
  from (select @get_ym:=in_ym p, @in_days:=in_days) p , v_organization_turnover s
 order by s.is_lump, s.employee_id;
END