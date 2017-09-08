delimiter //

DROP PROCEDURE IF EXISTS sp_organization_turnover //

CREATE PROCEDURE sp_organization_turnover(
    in_ym char(6)
)
BEGIN

select s.* from (select @get_ym:=in_ym p) p , v_organization_turnover s
 order by s.is_lump, s.employee_id;
END