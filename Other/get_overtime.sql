DROP FUNCTION IF EXISTS get_overtime

DELIMITER //

/* 残業時間を取得する */
CREATE FUNCTION get_overtime (raw_hours DECIMAL(5, 2),
                              min_hours DECIMAL(5, 2),
                              max_hours DECIMAL(5, 2),
                              is_hourly_pay boolean,
                              is_fixed_cost boolean,
                              is_reserve boolean) 
RETURNS DECIMAL(5, 2)
BEGIN

	DECLARE ret_value DECIMAL(5, 2);			/* 戻り値 */
    DECLARE total_hours DECIMAL(5, 2);  /* 深夜手当 */
    
    SET total_hours = get_attendance_total_hours(raw_hours);
    
    IF is_hourly_pay = 1 or is_fixed_cost = 1 or is_reserve = 1 THEN
		SET ret_value = 0;
    ELSEIF min_hours <= total_hours and total_hours <= max_hours THEN
		SET ret_value = 0;
	ELSEIF total_hours > max_hours THEN
		SET ret_value = total_hours - max_hours;
    ELSE
		SET ret_value = total_hours - min_hours;
    END IF;
    
    RETURN IFNULL(ret_value, 0);
 
END //

DELIMITER ;