/* 社員の稼働状況を取得する。
 *
 */

DELIMITER //

DROP FUNCTION IF EXISTS get_member_release_date //

/* 残業時間を取得する */
CREATE FUNCTION get_member_release_date (
	in_member_id integer
) 
RETURNS date
BEGIN

	DECLARE ret_value date;			/* 戻り値 */
    
    select max(pm.end_date) into ret_value
      from eb_projectmember pm
      join eb_project p on p.id = pm.project_id
	 where pm.member_id = in_member_id
       and pm.status = 2
       and pm.is_deleted = 0
       and p.is_deleted = 0
       and p.is_reserve = 0;
	
    IF ret_value < current_date() THEN
		SET ret_value = null;
	END IF;
	    
    RETURN ret_value;
 
END //

DELIMITER ;