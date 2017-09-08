DELIMITER //

DROP FUNCTION IF EXISTS set_ym //

/* 残業時間を取得する */
CREATE FUNCTION set_ym (
	in_ym char(6)
) 
RETURNS char(6)
BEGIN

	SET @get_ym:=in_ym;
    
    RETURN @get_ym;
 
END //

DELIMITER ;