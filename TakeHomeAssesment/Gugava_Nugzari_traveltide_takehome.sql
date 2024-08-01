--1.a Which cross-section of age and gender travels the most?
select
u.gender,
case when extract(year from age(s.session_start, u.birthdate)) < 18 then 'kids'
when extract(year from age(s.session_start, u.birthdate)) between 18 and 30 then '18 - 30'
when extract(year from age(s.session_start, u.birthdate)) between 30 and 40 then '30 - 40'
when extract(year from age(s.session_start, u.birthdate)) between 40 and 50 then '40 - 50'
when extract(year from age(s.session_start, u.birthdate)) between 50 and 60 then '50 - 60'
when extract(year from age(s.session_start, u.birthdate)) between 60 and 70 then '60 - 70'
else 'other'
end as age_groups,
count(s.trip_id)
from users as u
left join sessions as s
using(user_id)
where s.trip_id is not null
group by 1, 2;
/* The most active travelers are males and females 30 - 50 and 60 - 70 years old*/
-- 1.b How does the travel behavior of customers married with children compare
-- to childless single customers?
select
case when u.has_children = 'true' and u.married = 'true' and s.flight_booked = 'false' and s.hotel_booked = 'false'  
then 'married with children F0H0'
when u.has_children = 'true' and u.married = 'true' and s.flight_booked = 'true' and s.hotel_booked = 'false'  
then 'married with children F1H0'
when u.has_children = 'true' and u.married = 'true' and s.flight_booked = 'false' and s.hotel_booked = 'true'  
then 'married with children F0H1'
when u.has_children = 'true' and u.married = 'true' and s.flight_booked = 'true' and s.hotel_booked = 'true'  
then 'married with children F1H1'
when u.has_children = 'false' and u.married = 'false' and s.flight_booked = 'false' and s.hotel_booked = 'false'
then 'single and childless F0H0'
when u.has_children = 'false' and u.married = 'false' and s.flight_booked = 'true' and s.hotel_booked = 'false'
then 'single and childless F1H0'
when u.has_children = 'false' and u.married = 'false' and s.flight_booked = 'false' and s.hotel_booked = 'true'
then 'single and childless F0H1'
when u.has_children = 'false' and u.married = 'false' and s.flight_booked = 'true' and s.hotel_booked = 'true'
then 'single and childless F1H1'
else 'other'
end as user_status,
case when s.flight_discount = 'true' then 'yes'
else 'no'
end as discount_status,
count(u.user_id) as booking_qty,
avg(s.page_clicks) as avg_page_clicks

from users as u
left join sessions as s
using (user_id)
group by 1, 2

/* I discovered that childless and single customers use discounts three times more often than married customers with children.*/

/* 2.b Which demographics abandon sessions disproportionately more than average?*/
with abandoned_session as(
select
u.gender,
count(s.session_id) as qty_abandoned
from sessions as s
left join users as u
using(user_id)
where s.flight_booked = 'false' and s.hotel_booked = 'false'
group by 1),
booked_session as(
  select
u.gender,
count(s.session_id) as qty_booked
from sessions as s
left join users as u
using(user_id)
where s.flight_booked = 'true' or s.hotel_booked = 'true'
group by 1)

select
ab.gender,
bo.qty_booked * 1.0 / ab.qty_abandoned as proportion
from abandoned_session as ab
left join booked_session as bo
using(gender);

/* Female has more abandoned sessions the other groups*/

/* 3.a Explore how customer origin (e.g. home city) influences travel preferences.*/
select
u.home_airport,
avg(h.nights) as avg_nights,
count(f.trip_id) as qty_trips
from users as u
left join sessions as s
using(user_id)
left join flights as f
on s.trip_id = f.trip_id
left join hotels as h
on s.trip_id = h.trip_id
group by 1
order by 3 desc
/* Three airports stand out with a large number of travelers, this is JFK, LGA, LAX */


