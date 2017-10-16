delimiter //

DROP PROCEDURE IF EXISTS sp_dispatch_members //

CREATE PROCEDURE sp_dispatch_members(
    in_ym char(6)
)
BEGIN

select s.* from (select @get_ym:=in_ym p) p , v_dispatch_member s
order by s.client_name;

END