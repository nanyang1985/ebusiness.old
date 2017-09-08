CREATE OR REPLACE VIEW v_interval_dates AS
select distinct adddate('2010-01-01', INTERVAL t2.i*20 + t1.i*10 + t0.i MONTH) selected_date 
  from mst_interval t0
     , mst_interval t1
     , mst_interval t2
