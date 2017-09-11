delimiter //

DROP PROCEDURE IF EXISTS sp_organization_cost //

CREATE PROCEDURE sp_organization_cost(
    in_ym char(6)
)
BEGIN

select s.* from (select @get_ym:=in_ym p) p , v_organization_cost s
 order by s.is_lump, s.employee_id;
END