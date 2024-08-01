/* Question #1: 
Write a solution to find the employee_id of managers with at least 2 direct reports.


Expected column names: employee_id */

select
employee_id
from employee
where coalesce(reports_to, 0) < 2;

/*Question #2: 
Calculate total revenue for MPEG-4 video files purchased in 2024.

Expected column names: total_revenue */
with selected_invoice as(
select *
from invoice
where extract(year from invoice_date) = 2024),
mpeg_tracks as(
  select *
  from track
  where media_type_id = 3),
  invoice_line_mpeg as(
    select *
    from invoice_line
    where track_id in (select track_id from mpeg_tracks)),
    selected_files as(
    select
    invoice_id,
    track_id, unit_price, quantity
    from selected_invoice
    inner join invoice_line_mpeg
    using(invoice_id))
    select
    sum(unit_price * quantity) as total_revenue
    from selected_files;
	
	/* Question #3: 
For composers appearing in classical playlists, count the number of distinct playlists they appear on and create a comma separated list
of the corresponding (distinct) playlist names.

Expected column names: composer, distinct_playlists, list_of_playlists */

with selected_tracks as(
select *
from playlist_track
where playlist_id in (select playlist_id
                      from playlist
                      where name like '%Classical%')),
                      composers as(
                      select
                      distinct(t.composer)
                      from selected_tracks as s
                      inner join track as t
                      using(track_id)
                      where t.composer is not null),
                      joined_table as(
                      select
                      pt.playlist_id, pt.track_id, t.composer, p.name as playlist
                      from playlist_track as pt
                      left join track as t
                      using(track_id)
                      inner join playlist as p
                      using(playlist_id)
                      where composer in (select * from composers) and p.name like '%Classical%')             
                      select
                      composer,
                      count(distinct playlist) as distinct_playlists,
                      string_agg(distinct playlist, ', ') as list_of_playlists
                      from joined_table                      
                      group by 1;
					  					  
                      
/* Question #4: 
Find customers whose yearly total spending is strictly increasing*.


*read the hints!


Expected column names: customer_id */
with user_spend as(
select
customer_id,
extract(year from invoice_date) as year,
sum(total) as total

from invoice

group by 1, 2),
prev_total as(
select
customer_id,
year,
total,
lag(total) over (partition by customer_id order by year) as prev_total
from user_spend
where year <> 2025),
increase_table as(
select *, 
case when prev_total < total then 'true' else 'false' end as spend_increase
from prev_total)

select distinct customer_id
from increase_table
where customer_id not in(select  customer_id from increase_table where spend_increase = 'false' and prev_total is not null)
order by 1;
  



