CREATE OR REPLACE VIEW v_bp_request AS
select s.id
     , s.id as subcontractor_id
	 , s.name as subcontractor_name
	 , sr.year
	 , sr.month
     , max(srh.remit_date) as limit_date
	 , sum(sr.amount) as amount
	 , sum(sr.turnover_amount) as turnover_amount
	 , sum(sr.tax_amount) as tax_amount
	 , sum(sr.expenses_amount) as expenses_amount
  from eb_subcontractor s
  left join eb_subcontractorrequest sr on sr.subcontractor_id= s.id
  left join eb_subcontractorrequestheading srh on srh.subcontractor_request_id = sr.id
 group by s.id, s.name, sr.year, sr.month
