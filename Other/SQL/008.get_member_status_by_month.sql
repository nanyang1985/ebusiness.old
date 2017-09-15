/* 社員の稼働状況を取得する。
 *
 */

DELIMITER //

DROP FUNCTION IF EXISTS get_member_status_by_month //

/* 残業時間を取得する */
CREATE FUNCTION get_member_status_by_month (
	in_member_id integer,
    in_salesofreason_id integer,
	in_ym char(6)
) 
RETURNS char(2)
BEGIN

	DECLARE ret_value char(2);			/* 戻り値 */
    DECLARE project_count integer;
    DECLARE reverse_count integer;
    	
	select count(1) into project_count
	  from eb_projectmember pm
	  join eb_project p on p.id = pm.project_id
	 where pm.member_id = in_member_id
	   and pm.status = 2
	   and pm.is_deleted = 0
	   and extract(year_month from pm.start_date) <= in_ym
	   and extract(year_month from pm.end_date) >= in_ym
	   and p.is_deleted = 0
	   and p.is_reserve = 0;

    IF project_count > 0 THEN
		-- 現在実施中の案件を取得する
		SET ret_value = '01';	-- 稼働中
	ELSE
		select count(1) into reverse_count
		  from eb_projectmember pm
		  join eb_project p on p.id = pm.project_id
		 where pm.member_id = in_member_id
		   and pm.status = 2
		   and pm.is_deleted = 0
		   and extract(year_month from pm.start_date) <= in_ym
		   and extract(year_month from pm.end_date) >= in_ym
		   and p.is_deleted = 0
		   and p.is_reserve = 1;
		IF reverse_count = 0 THEN
			SET ret_value = '02';	-- 待機
		ELSE
			SET ret_value = '03';	-- 待機案件
        END IF;
	END IF;
    
    RETURN ret_value;
 
END //

DELIMITER ;