CREATE OR REPLACE VIEW v_turnover_dates AS
select DATE_FORMAT(selected_date, '%Y%m') as ym
  from v_interval_dates
 where selected_date between (select min(start_date) from eb_projectmember)
                         and current_date()