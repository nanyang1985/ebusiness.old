delimiter //

DROP PROCEDURE IF EXISTS proc_organization_turnover //

CREATE PROCEDURE proc_organization_turnover(
    in_ym char(6)
)
BEGIN

select * from
(
	select * 
      from v_organization_turnover
	 where ym = in_ym
) T
 order by T.is_lump, T.employee_id;
END