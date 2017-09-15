CREATE OR REPLACE VIEW v_turnover_dates AS
select DATE_FORMAT(selected_date, '%Y%m') as ym
     , DATE_FORMAT(selected_date, '%Y') as year
     , DATE_FORMAT(selected_date, '%m') as month
  from v_interval_dates
 where selected_date between '2016-05-01' and date_add(current_date(), interval 1 month)