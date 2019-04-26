/* 社員の部署を取得する。
 *
 */

DELIMITER //

DROP FUNCTION IF EXISTS get_min_hours //

/* ＢＰメンバーの諸経費を取得する */
CREATE FUNCTION get_min_hours (
    in_member_type integer,
    in_calculate_type char(2),
    in_days integer,
    in_min_hours DECIMAL(5, 2)
) 
RETURNS DECIMAL(5, 2)
BEGIN

    DECLARE ret_value DECIMAL(5, 2);            /* 戻り値 */
        
    IF in_member_type = 4 THEN
        IF in_calculate_type = '01' THEN
            SET ret_value = 160;
        ELSEIF in_calculate_type = '02' THEN
            SET ret_value = in_days * 8;
        ELSEIF in_calculate_type = '03' THEN
            SET ret_value = in_days * 7.9;
        ELSEIF in_calculate_type = '04' THEN
            SET ret_value = in_days * 7.75;
        ELSE
            SET ret_value = in_min_hours;
        END IF;
    ELSE
        SET ret_value = in_min_hours;
    END IF;
    
    RETURN ret_value;

END //

DELIMITER ;