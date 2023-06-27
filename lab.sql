-- 1) Get number of monthly active customers.
with cte_active_cust as 
	(select 
		customer_id, 
        date_format(convert(payment_date,date), '%m') as Activity_Month, 
        date_format(convert(payment_date,date), '%y') as Activity_year 
	from payment
    )
select activity_month, activity_year, count(distinct customer_id) as monthly_active_users from cte_active_cust
group by activity_year, activity_month
order by activity_year, activity_month;

-- 2) Active users in the previous month.
with cte_active_cust as 
	(select 
		customer_id, 
        date_format(convert(payment_date,date), '%m') as Activity_Month, 
        date_format(convert(payment_date,date), '%y') as Activity_year 
	from payment
    )
select activity_month, activity_year, count(distinct customer_id) as monthly_active_users, lag(count(distinct customer_id)) over (order by activity_year,activity_month) as previous_month_Active_users from cte_active_cust
group by activity_year, activity_month
order by activity_year, activity_month;

-- 3) Percentage change in the number of active customers.
with cte_active_cust as
	(select
		customer_id,
        date_format(convert(payment_date, date),'%m') as Activity_month,
        date_format(convert(payment_date, date),'%y') as Activity_year
	from payment
    ), cte_cust_list as 
	(select activity_year,activity_month, count(distinct(customer_id)) as monthly_active_users, lag(count(distinct(customer_id))) over (order by activity_year, activity_month) as previous_month_active_users from cte_active_cust
    group by activity_year, activity_month
    order by activity_year, activity_month)
    select *, (((monthly_active_users-previous_month_active_users)/previous_month_active_users)*100) as percentage_change from cte_cust_list;
    
    -- 4) Retained customers every month.
with cte_active_cust as
	(select
		customer_id,
        date_format(convert(payment_date, date),'%m') as Activity_month,
        date_format(convert(payment_date, date),'%y') as Activity_year
	from payment
    ), cte_recurrent as
    (select
		distinct customer_id as active_customer,
        activity_month, activity_year
	from cte_active_cust
    order by active_customer,activity_month,activity_year)
    select count(distinct(r1.active_customer)) as num_recurrent_customer
from cte_recurrent r1
join cte_recurrent r2 on r1.activity_year = r2.activity_year and
						 r1.activity_month = r2.activity_month + 1 and
                         r1.active_customer = r2.active_customer;

        
    