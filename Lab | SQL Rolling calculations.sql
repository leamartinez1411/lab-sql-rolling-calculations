-- Lab | SQL Rolling calculations
-- In this lab, you will be using the Sakila database of movie rentals.


-- Get number of monthly active customers.

create or replace view customer_activity as
select customer_id, convert(payment_date, date) as Activity_date,
date_format(convert(payment_date,date), '%m') as Activity_Month,
date_format(convert(payment_date,date), '%Y') as Activity_year
from sakila.payment;

select * from sakila.customer_activity;

create or replace view Monthly_active_customer as
select count(distinct customer_id) as Active_customer, Activity_year, Activity_Month
from customer_activity
group by Activity_year, Activity_Month
order by Activity_year, Activity_Month;

select * from sakila.Monthly_active_customer;

with cte_activity as (
  select Active_customer, lag(Active_customer,1) over (partition by Activity_year) as last_month, Activity_year, Activity_month
  from Monthly_active_customer
)
select * from cte_activity
where Activity_year=2006
and Activity_month=02 ;


-- Active users in the previous month.

create or replace view customer_activity as
select customer_id, convert(payment_date, date) as Activity_date,
date_format(convert(payment_date,date), '%m') as Activity_Month,
date_format(convert(payment_date,date), '%Y') as Activity_year
from sakila.payment;

select * from sakila.customer_activity;

create or replace view Monthly_active_customer as
select count(distinct customer_id) as Active_customer, Activity_year, Activity_Month
from customer_activity
group by Activity_year, Activity_Month
order by Activity_year, Activity_Month;

select * from sakila.Monthly_active_customer;

with cte_activity as (
  select Active_customer, lag(Active_customer,1) over (partition by Activity_year) as last_month, Activity_year, Activity_month
  from Monthly_active_customer
)
select * from cte_activity
where Activity_year=2006
and Activity_month=01 ;


-- Percentage change in the number of active customers.

create or replace view customer_activity as
select customer_id, convert(payment_date, date) as Activity_date,
date_format(convert(payment_date,date), '%m') as Activity_Month,
date_format(convert(payment_date,date), '%Y') as Activity_year
from sakila.payment;

select * from sakila.customer_activity;

create or replace view Monthly_active_customer as
select count(distinct customer_id) as Active_users, Activity_year, Activity_Month
from customer_activity
group by Activity_year, Activity_Month
order by Activity_year, Activity_Month;

select * from sakila.Monthly_active_customer;

with cte_activity as (
  select Active_users, (Active_users-(lag(Active_users,1) over (partition by Activity_year)))/(Active_users)*100 as percentage, 
  lag(Active_users,1) over (partition by Activity_year) as last_month, Activity_year, Activity_month
  from Monthly_active_customer
  )

select * from cte_activity
where last_month is not null;


-- Retained customers every month.

with retained_customer as (
  select customer_id, Activity_year, Activity_Month
  from customer_activity
)
select count(distinct d1.customer_id) as retained_customer, d1.Activity_Month, d1.Activity_year
from retained_customer d1
join retained_customer d2 on d1.customer_id = d2.customer_id
and d1.Activity_month = d2.Activity_month + 1
group by d1.Activity_month, d1.Activity_year ; 