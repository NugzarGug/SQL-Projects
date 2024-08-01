/*Question #1: 
Vibestream is designed for users to share brief updates about how they are feeling,
as such the platform enforces a character limit of 25. How many posts are exactly 25 characters long? */

select
count(content) as char_limit_posts
from posts
where length(content) = 25;

/*Question #2: 
Users JamesTiger8285 and RobertMermaid7605 are Vibestream’s most active posters.

Find the difference in the number of posts these two users made on each day that at least one of them made
a post. Return dates where the absolute value of the difference between posts made is greater than 2
(i.e dates where JamesTiger8285 made at least 3 more posts than RobertMermaid7605 or vice versa). */

with combined_table as(
  select p.post_date, u.user_name, p.post_id
  from users as u
  left join posts as p
  using(user_id)
  where u.user_name = 'JamesTiger8285' or u.user_name = 'RobertMermaid7605'),
  groupped_table as(
  select post_date, user_name, count(post_id) as post_qty
  from combined_table
  group by 1, 2),
  posts_table as(
  select 
  post_date,
  case when user_name = 'JamesTiger8285'
  then post_qty else 0 end as james_posts_qty,
  case when user_name = 'RobertMermaid7605'
  then post_qty else 0 end as robert_posts_qty
  from groupped_table),
  date_groupped as(
  select
  post_date,
  sum(james_posts_qty) as sum_james,
  sum(robert_posts_qty) as sum_robert
  from posts_table
  group by 1)
  select 
  post_date
  from date_groupped
  where sum_james - sum_robert > 2 or sum_robert - sum_james > 2;

/*Question #3: 
Most users have relatively low engagement and few connections. User WilliamEagle6815, for example, has only 2 followers. 

Network Analysts would say this user has two 1-step path relationships. 
Having 2 followers doesn’t mean WilliamEagle6815 is isolated, however. 
Through his followers, he is indirectly connected to the larger Vibestream network. 

Consider all users up to 3 steps away from this user:

1-step path (X → WilliamEagle6815)
2-step path (Y → X → WilliamEagle6815)
3-step path (Z → Y → X → WilliamEagle6815)

Write a query to find follower_id of all users within 4 steps of WilliamEagle6815.
Order by follower_id and return the top 10 records. */

with user_id as(
select distinct(p.user_id)
from posts as p
left join users as u
using(user_id)
where u.user_name = 'WilliamEagle6815'),
followers_1 as(
select 
f.follower_id
from follows as f
where f.followee_id = (select user_id from user_id)),
followers_2 as(
select f.follower_id
from follows as f
where f.followee_id in(select * from followers_1)),
followers_3 as(select f.follower_id
from follows as f
where f.followee_id in(select * from followers_2)),
all_followers as(
select *
from followers_1
union all
select *
from followers_2
union all
select *
from followers_3)
select distinct(follower_id)
from follows
where followee_id in(select * from all_followers)
order by 1 asc
limit 10;

/*Question #4: 
Return top posters for 2023-11-30 and 2023-12-01. A top poster is a user who has the most OR second most number of posts
in a given day. Include the number of posts in the result and order the result by post_date and user_id. */

with selected_posts as(
select
p.post_date,
p.user_id,
count(p.post_id) as posts_qty
from posts as p
where p.post_date = '2023-11-30' or p.post_date = '2023-12-01'
group by 1, 2),
ranked_table as(
select post_date, user_id, posts_qty
from (select post_date, user_id, posts_qty,
      dense_rank() over(partition by post_date order by posts_qty desc) as rank
      from selected_posts) as ranked_data
      where rank = 1 or rank = 2)
      select * from ranked_table
      order by post_date, user_id;
