/* 社員の部署を取得する。
 *
 */

DELIMITER //

DROP FUNCTION IF EXISTS get_department //

/* ＢＰメンバーの諸経費を取得する */
CREATE FUNCTION get_department (
	in_member_id integer,
    in_year char(4),
    in_month char(2)
) 
RETURNS integer
BEGIN

	DECLARE ret_value integer;			/* 戻り値 */
    DECLARE t_division_id integer;
    DECLARE t_section_id integer;
    DECLARE t_subsection_id integer;
    
    select msp.division_id, msp.section_id, msp.subsection_id
      into t_division_id, t_section_id, t_subsection_id
      from eb_membersectionperiod msp 
	 where msp.is_deleted = 0 
       and msp.member_id = in_member_id 
       and date_format(msp.start_date, '%Y%m') <= concat(in_year, in_month) 
       and (date_format(msp.end_date, '%Y%m') >= concat('2017', '04') or msp.end_date is null)
	 limit 1;
	
    IF t_division_id is not null THEN
        SET ret_value = t_division_id;
	ELSEIF t_section_id is not null THEN
		SET ret_value = t_section_id;
	ELSEIF t_subsection_id is not null THEN
		SET ret_value = t_subsection_id;
	END IF;
	
    RETURN ret_value;

END //

DELIMITER ;