CREATE OR REPLACE VIEW v_client_request AS
select c.id
     , c.id as client_id
	 , c.name as client_name
	 , pr.year
	 , pr.month
	 , sum(pr.amount) as amount
	 , sum(pr.turnover_amount) as turnover_amount
	 , sum(pr.tax_amount) as tax_amount
	 , sum(pr.expenses_amount) as expenses_amount
  from eb_client c
  join eb_project p on p.client_id = c.id
  left join eb_projectrequest pr on pr.project_id = p.id
 group by c.id, c.name, pr.year, pr.month
