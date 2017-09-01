USE `eb_sales`;
CREATE OR REPLACE ALGORITHM = UNDEFINED
VIEW `v_contract` AS
    SELECT 
        `eb_contract`.`id` AS `id`,
        `eb_contract`.`contract_no` AS `contract_no`,
        `eb_contract`.`contract_date` AS `contract_date`,
        `eb_contract`.`member_type` AS `member_type`,
        `eb_contract`.`employment_date` AS `employment_date`,
        `eb_contract`.`start_date` AS `start_date`,
        (CASE
            WHEN (`eb_contract`.`end_date2` IS NOT NULL) THEN `eb_contract`.`end_date2`
            ELSE `eb_contract`.`end_date`
        END) AS `end_date`,
        `eb_contract`.`employment_period_comment` AS `employment_period_comment`,
        `eb_contract`.`position` AS `position`,
        `eb_contract`.`business_address` AS `business_address`,
        `eb_contract`.`business_type` AS `business_type`,
        `eb_contract`.`business_type_other` AS `business_type_other`,
        `eb_contract`.`business_other` AS `business_other`,
        `eb_contract`.`business_time` AS `business_time`,
        `eb_contract`.`is_hourly_pay` AS `is_hourly_pay`,
        0 AS `is_fixed_cost`,
        0 AS `is_show_formula`,
        `eb_contract`.`allowance_base` AS `allowance_base`,
        `eb_contract`.`allowance_base_memo` AS `allowance_base_memo`,
        `eb_contract`.`allowance_base_other` AS `allowance_base_other`,
        `eb_contract`.`allowance_base_other_memo` AS `allowance_base_other_memo`,
        `eb_contract`.`allowance_work` AS `allowance_work`,
        `eb_contract`.`allowance_work_memo` AS `allowance_work_memo`,
        `eb_contract`.`allowance_director` AS `allowance_director`,
        `eb_contract`.`allowance_director_memo` AS `allowance_director_memo`,
        `eb_contract`.`allowance_position` AS `allowance_position`,
        `eb_contract`.`allowance_position_memo` AS `allowance_position_memo`,
        `eb_contract`.`allowance_diligence` AS `allowance_diligence`,
        `eb_contract`.`allowance_diligence_memo` AS `allowance_diligence_memo`,
        `eb_contract`.`allowance_security` AS `allowance_security`,
        `eb_contract`.`allowance_security_memo` AS `allowance_security_memo`,
        `eb_contract`.`allowance_qualification` AS `allowance_qualification`,
        `eb_contract`.`allowance_qualification_memo` AS `allowance_qualification_memo`,
        `eb_contract`.`allowance_traffic` AS `allowance_traffic`,
        `eb_contract`.`allowance_traffic_memo` AS `allowance_traffic_memo`,
        `eb_contract`.`allowance_time_min` AS `allowance_time_min`,
        `eb_contract`.`allowance_time_max` AS `allowance_time_max`,
        '' AS `allowance_time_memo`,
        '99' AS `calculate_type`,
        0 AS `calculate_time_min`,
        0 AS `calculate_time_max`,
        `eb_contract`.`allowance_overtime` AS `allowance_overtime`,
        `eb_contract`.`allowance_overtime_memo` AS `allowance_overtime_memo`,
        `eb_contract`.`allowance_absenteeism` AS `allowance_absenteeism`,
        `eb_contract`.`allowance_absenteeism_memo` AS `allowance_absenteeism_memo`,
        `eb_contract`.`allowance_other` AS `allowance_other`,
        `eb_contract`.`allowance_other_memo` AS `allowance_other_memo`,
        `eb_contract`.`endowment_insurance` AS `endowment_insurance`,
        `eb_contract`.`allowance_ticket_comment` AS `allowance_ticket_comment`,
        `eb_contract`.`allowance_date_comment` AS `allowance_date_comment`,
        `eb_contract`.`allowance_change_comment` AS `allowance_change_comment`,
        `eb_contract`.`bonus_comment` AS `bonus_comment`,
        `eb_contract`.`holiday_comment` AS `holiday_comment`,
        `eb_contract`.`paid_vacation_comment` AS `paid_vacation_comment`,
        `eb_contract`.`non_paid_vacation_comment` AS `non_paid_vacation_comment`,
        `eb_contract`.`retire_comment` AS `retire_comment`,
        `eb_contract`.`status` AS `status`,
        `eb_contract`.`comment` AS `comment`,
        `eb_contract`.`member_id` AS `member_id`,
        7 AS `content_type_id`,
        `eb_contract`.`company_id` AS `company_id`,
        `eb_contract`.`is_loan` AS `is_loan`,
        `eb_contract`.`move_flg` AS `move_flg`,
        (CASE
            WHEN
                 (SELECT
                        MAX(`c1`.`contract_no`)
                    FROM
                        `eb_contract` `c1`
                    WHERE
                        ((`c1`.`start_date` = `eb_contract`.`start_date`)
                            AND (`c1`.`member_id` = `eb_contract`.`member_id`)
                            AND (`c1`.`is_deleted` = 0)
                            AND (`c1`.`status` <> '04')) = `eb_contract`.`contract_no`)
            THEN
                0
            ELSE 1
        END) AS `is_old`,
        (CASE
            WHEN
                EXISTS( SELECT
                        1
                    FROM
                        `eb_contract` `c1`
                    WHERE
                        ((`c1`.`start_date` < `eb_contract`.`start_date`)
                            AND (`c1`.`member_id` = `eb_contract`.`member_id`)))
            THEN
                `eb_contract`.`contract_no`
            ELSE '入社日'
        END) AS `auto_comment`,
        `eb_contract`.`created_date` AS `created_date`,
        `eb_contract`.`updated_date` AS `updated_date`,
        `eb_contract`.`is_deleted` AS `is_deleted`,
        `eb_contract`.`deleted_date` AS `deleted_date`
    FROM
        `eb_contract`
    UNION ALL SELECT
        `eb_bp_contract`.`id` AS `id`,
        NULL AS `contract_no`,
        NULL AS `contract_date`,
        4 AS `member_type`,
        NULL AS `employment_date`,
        `eb_bp_contract`.`start_date` AS `start_date`,
        `eb_bp_contract`.`end_date` AS `end_date`,
        '' AS `employment_period_comment`,
        '' AS `position`,
        '' AS `business_address`,
        '' AS `business_type`,
        '' AS `business_type_other`,
        '' AS `business_other`,
        '' AS `business_time`,
        `eb_bp_contract`.`is_hourly_pay` AS `is_hourly_pay`,
        `eb_bp_contract`.`is_fixed_cost` AS `is_fixed_cost`,
        `eb_bp_contract`.`is_show_formula` AS `is_show_formula`,
        `eb_bp_contract`.`allowance_base` AS `allowance_base`,
        `eb_bp_contract`.`allowance_base_memo` AS `allowance_base_memo`,
        '' AS `allowance_base_other`,
        '' AS `allowance_base_other_memo`,
        '' AS `allowance_work`,
        '' AS `allowance_work_memo`,
        '' AS `allowance_director`,
        '' AS `allowance_director_memo`,
        '' AS `allowance_position`,
        '' AS `allowance_position_memo`,
        '' AS `allowance_diligence`,
        '' AS `allowance_diligence_memo`,
        '' AS `allowance_security`,
        '' AS `allowance_security_memo`,
        '' AS `allowance_qualification`,
        '' AS `allowance_qualification_memo`,
        '' AS `allowance_traffic`,
        '' AS `allowance_traffic_memo`,
        `eb_bp_contract`.`allowance_time_min` AS `allowance_time_min`,
        `eb_bp_contract`.`allowance_time_max` AS `allowance_time_max`,
        `eb_bp_contract`.`allowance_time_memo` AS `allowance_time_memo`,
        `eb_bp_contract`.`calculate_type` AS `calculate_type`,
        `eb_bp_contract`.`calculate_time_min` AS `calculate_time_min`,
        `eb_bp_contract`.`calculate_time_max` AS `calculate_time_max`,
        `eb_bp_contract`.`allowance_overtime` AS `allowance_overtime`,
        `eb_bp_contract`.`allowance_overtime_memo` AS `allowance_overtime_memo`,
        `eb_bp_contract`.`allowance_absenteeism` AS `allowance_absenteeism`,
        `eb_bp_contract`.`allowance_absenteeism_memo` AS `allowance_absenteeism_memo`,
        `eb_bp_contract`.`allowance_other` AS `allowance_other`,
        `eb_bp_contract`.`allowance_other_memo` AS `allowance_other_memo`,
        '0' AS `endowment_insurance`,
        '' AS `allowance_ticket_comment`,
        '' AS `allowance_date_comment`,
        '' AS `allowance_change_comment`,
        '' AS `bonus_comment`,
        '' AS `holiday_comment`,
        '' AS `paid_vacation_comment`,
        '' AS `non_paid_vacation_comment`,
        '' AS `retire_comment`,
        '' AS `status`,
        `eb_bp_contract`.`comment` AS `comment`,
        `eb_bp_contract`.`member_id` AS `member_id`,
        8 AS `content_type_id`,
        `eb_bp_contract`.`company_id` AS `company_id`,
        0 AS `is_loan`,
        0 AS `move_flg`,
        0 AS `is_old`,
        '' AS `auto_comment`,
        `eb_bp_contract`.`created_date` AS `created_date`,
        `eb_bp_contract`.`updated_date` AS `updated_date`,
        `eb_bp_contract`.`is_deleted` AS `is_deleted`,
        `eb_bp_contract`.`deleted_date` AS `deleted_date`
    FROM
        `eb_bp_contract`;