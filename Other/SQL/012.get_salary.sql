/* メンバーの給料を取得する
 *
 * 残業／控除含まれています。
 */

DELIMITER //

DROP FUNCTION IF EXISTS get_salary //

/* ＢＰメンバーの諸経費を取得する */
CREATE FUNCTION get_salary (
	in_contract_id integer,
    in_bp_contract_id integer,
    in_total_hours integer,
    in_total_hours_bp integer
)
RETURNS integer
BEGIN

	DECLARE ret_value integer;					/* 戻り値 */
    DECLARE v_overtime_cost integer;				/* 残業／控除 */
    DECLARE v_member_type integer;
    DECLARE v_is_hourly_pay boolean;				/* 時給 */
    DECLARE v_is_fixed_cost boolean;
    DECLARE v_allowance_base integer;
    DECLARE v_allowance_base_other integer;
    DECLARE v_allowance_work integer;
    DECLARE v_allowance_director integer;
    DECLARE v_allowance_position integer;
    DECLARE v_allowance_diligence integer;
    DECLARE v_allowance_security integer;
    DECLARE v_allowance_qualification integer;
    DECLARE v_allowance_other integer;
    
    DECLARE v_allowance_time_min decimal(5, 2);
    DECLARE v_allowance_time_max decimal(5, 2);
    DECLARE v_allowance_overtime integer;
    DECLARE v_allowance_absenteeism integer;
    
    IF (in_total_hours is null or in_total_hours = 0) and (in_total_hours_bp is null or in_total_hours_bp = 0) THEN
		RETURN 0;
    ELSEIF in_contract_id is not null and in_contract_id > 0 THEN
        select member_type, is_hourly_pay, 0
             , allowance_base, allowance_base_other, allowance_work, allowance_director, allowance_position, allowance_diligence, allowance_security, allowance_qualification, allowance_other
             , allowance_time_min, allowance_time_max, allowance_overtime, allowance_absenteeism
          into v_member_type, v_is_hourly_pay, v_is_fixed_cost
             , v_allowance_base, v_allowance_base_other, v_allowance_work, v_allowance_director, v_allowance_position, v_allowance_diligence, v_allowance_security, v_allowance_qualification, v_allowance_other
             , v_allowance_time_min, v_allowance_time_max, v_allowance_overtime, v_allowance_absenteeism
          from eb_contract where id = in_contract_id;
	ELSEIF in_bp_contract_id is not null and in_bp_contract_id > 0 THEN
		select 4, is_hourly_pay, is_fixed_cost, allowance_base, allowance_other
             , allowance_time_min, allowance_time_max, allowance_overtime, allowance_absenteeism
          into v_member_type, v_is_hourly_pay, v_is_fixed_cost, v_allowance_base, v_allowance_other
             , v_allowance_time_min, v_allowance_time_max, v_allowance_overtime, v_allowance_absenteeism
          from eb_bp_contract where id = in_bp_contract_id;
	END IF;
    
    IF v_is_hourly_pay = 1 THEN
		-- 時給の場合
		SET ret_value = v_allowance_base * get_attendance_total_hours(IF(in_total_hours_bp is null or in_total_hours_bp = 0, IFNULL(in_total_hours, 0), in_total_hours_bp)) + v_allowance_other;
	ELSEIF v_is_fixed_cost = 1 THEN
		-- 固定の場合
        SET ret_value = v_allowance_base;
    ELSEIF v_is_hourly_pay = 0 and v_is_fixed_cost = 0 THEN
		IF v_member_type = 1 THEN
			SET ret_value = truncate((v_allowance_base + v_allowance_base_other + v_allowance_work + v_allowance_director + v_allowance_position + v_allowance_diligence + v_allowance_security + v_allowance_qualification + v_allowance_other) * 14 / 12, 0);
		ELSEIF v_member_type = 4 THEN
			SET ret_value = v_allowance_base + v_allowance_other;
		ELSE
			SET ret_value = v_allowance_base + v_allowance_base_other + v_allowance_work + v_allowance_director + v_allowance_position + v_allowance_diligence + v_allowance_security + v_allowance_qualification + v_allowance_other;
		END IF;
        
        -- 残業／控除
        SET v_overtime_cost = get_overtime_cost(IF(in_total_hours_bp is null or in_total_hours_bp = 0, IFNULL(in_total_hours, 0), in_total_hours_bp), v_allowance_time_min, v_allowance_time_max, 0, 0, 0, v_allowance_absenteeism, v_allowance_overtime);
        SET ret_value = ret_value + v_overtime_cost;
	END IF;
	
    RETURN ret_value;
 
END //

DELIMITER ;