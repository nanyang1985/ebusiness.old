delimiter //

DROP PROCEDURE IF EXISTS sp_sales_member //

CREATE PROCEDURE sp_sales_member(
    in_ym char(6)
)
BEGIN

select s.* from (select @get_ym:=in_ym p) p , v_sales_member s;

END