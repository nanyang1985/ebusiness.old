DELIMITER //

DROP FUNCTION IF EXISTS get_days //

/* 残業時間を取得する */
CREATE FUNCTION get_days () 
returns integer DETERMINISTIC NO SQL return @get_days; //

DELIMITER ;