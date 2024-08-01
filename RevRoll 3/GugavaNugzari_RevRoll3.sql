/*Question #1: 
Identify installers who have participated in at least one installer competition by name.


Expected column names: name  */

select  i.name
from installers as i
where i.installer_id in(select installer_one_id from install_derby) 
or i.installer_id in(select installer_two_id from install_derby);

/*Question #2: 
Write a solution to find the third transaction of every customer, where the spending on the preceding two transactions 
is lower than the spending on the third transaction. Only consider transactions that include an installation, 
and return the result table by customer_id in ascending order.

Expected column names: customer_id, third_transaction_spend, third_transaction_date */
with joined_table as(
select 
c.customer_id,
i.install_date,
o.order_id, o.part_id, (o.quantity * p.price) as spending
from customers as c
left join orders as o
using(customer_id)
left join installs as i
using(order_id)
left join parts as p
using(part_id)
where i.install_date is not null
order by 1, 2 asc),
numbered_transactions as(
select 
*, row_number() over(partition by customer_id order by install_date asc, spending desc) as row_num
from joined_table),
selected_transactions as(
select *
from numbered_transactions
where row_num < 4),
selected_id as( select customer_id,
               max(spending) as max_spend
               from selected_transactions
               
               group by 1
              order by 1),
              second_join as(
               
               select s.*, i.max_spend from selected_transactions as s
               left join selected_id as i
               using(customer_id)),
               flag_table as(
               select customer_id, install_date, spending,              
               case when spending = max_spend  and row_num = 3  then 'y' else 'n' end as flag,
               case when spending = max_spend then 'y' else 'n' end as second_flag,
                 row_num
               from second_join),
               excluded_id as(
               select 
               case when second_flag = 'y' and row_num = 1 or second_flag = 'y' and row_num = 2 then customer_id end as customer_id
               from flag_table)   
               
               select customer_id,
               spending as third_transaction_spend,
               install_date as third_transaction_date
               from flag_table
               where flag = 'y' and second_flag = 'y'
               and customer_id not in (select customer_id from excluded_id where customer_id is not null);
			   
/*Question #3: 
Write a solution to report the most expensive part in each order. Only include installed orders. In case of a tie, report all parts with the maximum price. 
Order by order_id and limit the output to 5 rows.

Expected column names: order_id, part_id */


with joined_table as(select
                     o.order_id, 
                     p.part_id,
                     p.price
                     from installs as i
                     left join orders as o
                     using(order_id)
                     left join parts as p
                     using(part_id)),
        
                    selected_orders as(
                     select 
                     order_id,
                     part_id,
                     max(price) as max_price
                     from joined_table
                     where order_id is not null
                     group by 1, 2
                     order by 1)
                     
                     select 
                     order_id,
                     part_id
                     from joined_table
                     where order_id in (select order_id from selected_orders)
                     order by 1
                     limit 5;
					 
/*Question #4: 
Write a query to find the installers who have completed installations for at least four consecutive days. Include the installer_id, 
start date of the consecutive installations period and the end date of the consecutive installations period. 

Return the result table ordered by installer_id in ascending order.

Expected column names: installer_id, consecutive_start, consecutive_end */
with installers as(
select 
installer_id,
install_date
from installs
group by 1, 2
order by 1, 2),
install_dates as(
  select 
  installer_id,
  install_date,
lag(install_date, 1) over(partition by installer_id order by install_date)  as prev_date1,
lag(install_date, 2) over(partition by installer_id order by install_date)  as prev_date2,
lag(install_date, 3) over(partition by installer_id order by install_date)  as prev_date3
from installers)

select
installer_id,
prev_date3 as consecutive_start,
install_date as consecutive_end
from install_dates
where
install_date = prev_date1 + interval '1 day'
and install_date = prev_date2 + interval '2 day'
and install_date = prev_date3 + interval '3 day';
