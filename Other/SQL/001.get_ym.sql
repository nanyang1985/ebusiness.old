DELIMITER //

DROP FUNCTION IF EXISTS get_ym //

/* 残業時間を取得する */
CREATE FUNCTION get_ym () 
returns CHAR(6) DETERMINISTIC NO SQL return @get_ym; //

DELIMITER ;