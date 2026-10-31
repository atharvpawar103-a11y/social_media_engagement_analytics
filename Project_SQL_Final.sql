
/*Exploring the tabales */
use social_media;

SELECT 
    *
FROM
    comments;
SELECT 
    *
FROM
    followers;
SELECT 
    *
FROM
    hashtags;
SELECT 
    *
FROM
    likes;
SELECT 
    *
FROM
    post_hashtags;
SELECT 
    *
FROM
    posts;
SELECT 
    *
FROM
    users;

/*
Task Overview (Learner Deliverables)
*/
/*
1.Find the most active users (by posts + comments).
*/
SELECT 
    username,
    country,
    COUNT(DISTINCT p.post_id) AS Post_activity,
    COUNT(DISTINCT cm.comment_id) AS Comment_activity,
    COUNT(DISTINCT p.post_id) + COUNT(DISTINCT cm.comment_id) AS Total_activity
FROM
    users u
        LEFT JOIN
    posts p ON p.user_id = u.user_id
        LEFT JOIN
    comments cm ON cm.user_id = u.user_id
GROUP BY u.user_id , username
ORDER BY Total_activity DESC
LIMIT 10
;
 

/*
2.Identify the most 
liked posts and their creators.
*/

SELECT 
    username,    p.post_id, content, COUNT(like_id) AS Total_likes
FROM
    users u
        JOIN
    posts p ON p.user_id = u.user_id
        JOIN
    likes l ON l.post_id = p.post_id
GROUP BY u.username , p.post_id
ORDER BY Total_likes DESC;

/*Top 10 User with most liked posts and their creators. */
SELECT 
    p.post_id,username, COUNT(like_id) AS Total_likes
FROM
    users u
        JOIN
    posts p ON p.user_id = u.user_id
        JOIN
    likes l ON l.post_id = p.post_id
GROUP BY u.username , p.post_id
ORDER BY Total_likes DESC
LIMIT 10;

/*
3.Find top 5 countries by 
average engagement (likes per post).
*/

SELECT 
    u.country,
    ROUND(COUNT(like_id) / COUNT(DISTINCT p.post_id),
            2) AS Avg_engagment
FROM
    users u
        JOIN
    posts p ON u.user_id = p.user_id
        LEFT JOIN
    likes l ON l.post_id = p.post_id
GROUP BY country
ORDER BY Avg_engagment DESC
LIMIT 5;

/*
4.Discover trending  -- please there are no responses
hashtags (used in >20 posts).
*/
with Hashtag_table as (
    select tag_name,
	count(p.post_id) over (partition by tag_name) as No_Hashtags
				from hashtags h 
				join post_hashtags ph
				on h.hashtag_id = ph.hashtag_id
				join posts p
				on p.post_id = ph.post_id
				order by No_Hashtags desc )

select distinct tag_name,  No_Hashtags
from  Hashtag_table
where  No_Hashtags>20;

/*
Q4  Discover trending hashtags (used in >7 posts).
*/
with Hashtag_table as (
    select tag_name,
	count(p.post_id) over (partition by tag_name) as No_Hashtags
				from hashtags h 
				join post_hashtags ph
				on h.hashtag_id = ph.hashtag_id
				join posts p
				on p.post_id = ph.post_id
				order by No_Hashtags desc )

select distinct tag_name,  No_Hashtags
from  Hashtag_table
where  No_Hashtags>7;



/*5.Identify top influencers 
(users with most followers).
*/

With infuencer_table as (select username,
count(follower_user_id) over(partition by u.user_id) as top_infuencers
from users u 
join followers f 
on u.user_id = f.user_id
)
 select distinct username ,top_infuencers
 from infuencer_table 
 order by top_infuencers desc
 limit 5;   
 
 /*
 6.Find users who follow 
 others but never like or comment.
 */
 SELECT DISTINCT
    username, u.user_id
FROM
    users u
        JOIN
    followers f ON u.user_id = f.follower_user_id
        LEFT JOIN
    likes l ON l.user_id = u.user_id
        LEFT JOIN
    comments c ON c.user_id = u.user_id
WHERE
    c.comment_id IS NULL
        AND l.like_id IS NULL;

/* Using NOT EXISTS */
SELECT
    u.user_id,
    u.username
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM followers f
    WHERE f.follower_user_id = u.user_id
)
AND NOT EXISTS (
    SELECT 1
    FROM likes l
    WHERE l.user_id = u.user_id
)
AND NOT EXISTS (
    SELECT 1
    FROM comments c
    WHERE c.user_id = u.user_id
);



/*
Identify inactive users with following_count
*/
SELECT DISTINCT
    username,
    u.user_id,
    COUNT(DISTINCT f.user_id) AS following_count
FROM
    users u
        JOIN
    followers f ON u.user_id = f.follower_user_id
        LEFT JOIN
    likes l ON l.user_id = u.user_id
        LEFT JOIN
    comments c ON c.user_id = u.user_id
WHERE
    c.comment_id IS NULL
        AND l.like_id IS NULL
GROUP BY u.user_id
ORDER BY following_count DESC
LIMIT 10;

/* 
7.Find hashtags with the 
highest engagement (likes + comments).
*/
SELECT 
    tag_name, COUNT(comment_id) + COUNT(like_id) AS Engagment_No
FROM
    posts p
        JOIN
    post_hashtags ph ON p.post_id = ph.post_id
        JOIN
    likes l ON l.post_id = p.post_id
        JOIN
    comments c ON c.post_id = p.post_id
        JOIN
    hashtags ht ON ht.hashtag_id = ph.hashtag_id
GROUP BY tag_name
ORDER BY Engagment_No DESC;

/*7.Find hashtags with the 
highest engagement (likes + comments).
Top-10
*/
SELECT 
    tag_name, COUNT(comment_id) + COUNT(like_id) AS Engagment_No
FROM
    posts p
        JOIN
    post_hashtags ph ON p.post_id = ph.post_id
        JOIN
    likes l ON l.post_id = p.post_id
        JOIN
    comments c ON c.post_id = p.post_id
        JOIN
    hashtags ht ON ht.hashtag_id = ph.hashtag_id
GROUP BY tag_name
ORDER BY Engagment_No DESC
LIMIT 10;

 /*8 Find the busiest hours or 
 days for posting activity.*/
  
 select distinct
 hour(created_at)as Posting_hour,
 count(post_id) over(partition by hour(created_at) ) as Total_post_per_hr
  from posts
  order by Total_post_per_hr desc;
 
 /*
  days for posting activity.
 */
SELECT DISTINCT
    DAYNAME(created_at) AS Post_Day,
    DAYOFWEEK(created_at) AS Day_number,
    COUNT(post_id) AS Total_Post_Per_Day
FROM
    posts
GROUP BY DAYNAME(created_at) , DAYOFWEEK(created_at)
ORDER BY Day_number;
 
 
 /*9 Identify inactive users 
 (no posts, likes, or comments).*/
 
 select distinct
 username,
 count(c.comment_id) over(partition by u.user_id) as No_of_comments,
 count(l.like_id) over(partition by u.user_id) as No_of_likes,
 count(p.post_id) over(partition by u.user_id) as No_of_post
 from users u
	 left join likes l 
		  on u.user_id = l.user_id
	 left join comments c
		  on c.user_id = u.user_id
	 left join posts p
		  on p.user_id = u.user_id
 where c.comment_id is null and 
 p.post_id is null and 
 l.like_id is null ;
 
 
 /*
 10	List top 5 countries 
 with most influencers.
 */
 
SELECT 
    country, COUNT(DISTINCT u.user_id) AS No_of_followers
FROM
    users u
        JOIN
    followers f ON u.user_id = f.user_id
GROUP BY u.country
ORDER BY No_of_followers DESC
LIMIT 5;



/*12. Bonus Challenges*/
/*
01. Calculate 
engagement rate = (likes + comments) / posts.
*/

with engagement_table as  (
SELECT 
    username,
    u.user_id,
    COUNT(DISTINCT l.like_id) AS No_likes,
    COUNT(DISTINCT c.comment_id) AS No_comments,
    COUNT(DISTINCT p.post_id) AS No_post
FROM
    users u
        LEFT JOIN
    likes l ON u.user_id = l.user_id
        LEFT JOIN
    comments c ON c.user_id = u.user_id
        LEFT JOIN
    posts p ON p.user_id = u.user_id
GROUP BY username , u.user_id )

SELECT 
    username,
    (No_likes + No_comments) AS Total_likes_comments,
    ROUND(((No_likes + No_comments) / No_post), 2) AS Engagment_rate
FROM
    engagement_table
ORDER BY Engagment_rate DESC;










/*
01. Calculate 
engagement rate = (likes + comments) / posts.
top 5 according to engagment rate
*/
with engagement_table as  (
SELECT 
    username,
    u.user_id,
    COUNT(DISTINCT l.like_id) AS No_likes,
    COUNT(DISTINCT c.comment_id) AS No_comments,
    COUNT(DISTINCT p.post_id) AS No_post
FROM
    users u
        LEFT JOIN
    likes l ON u.user_id = l.user_id
        LEFT JOIN
    comments c ON c.user_id = u.user_id
        LEFT JOIN
    posts p ON p.user_id = u.user_id
GROUP BY username , u.user_id )

SELECT 
    username,
    (No_likes + No_comments) AS Total_likes_comments,
    ROUND(((No_likes + No_comments) / No_post), 2) AS Engagment_rate
FROM
    engagement_table
ORDER BY Engagment_rate DESC
LIMIT 5;




/*
02.Identify mutual followers.
*/
SELECT 
    u1.username AS User_1, u2.username AS User_2
FROM
    followers f1
        JOIN
    followers f2 ON f1.user_id = f2.follower_user_id
        AND f1.follower_user_id = f2.user_id
        JOIN
    users u1 ON u1.user_id = f1.user_id
        JOIN
    users u2 ON u2.user_id = f1.user_id;





/*
03. Find most used hashtags
 by top 5 influencers.
*/

with followers_table as (SELECT 
    username,
    u.user_id,
    COUNT(DISTINCT follower_user_id) AS No_of_followers
FROM
    users u
        JOIN
    followers f ON u.user_id = f.user_id
GROUP BY username , u.user_id
ORDER BY No_of_followers DESC
LIMIT 5)

SELECT 
    tag_name, username, COUNT(p.post_id) AS No_Hashtages
FROM
    followers_table ft
        JOIN
    posts p ON p.user_id = ft.user_id
        JOIN
    post_hashtags ph ON ph.post_id = p.post_id
        JOIN
    hashtags h ON h.hashtag_id = ph.hashtag_id
GROUP BY tag_name , username;

/*Hastags according to usages

*/

with Top_5_influencers as (

select u.user_id,
u.username,
count(distinct f.follower_user_id  ) as No_of_followers
from users u
join followers f
on u.user_id = f.user_id
group by u.user_id,
u.username
order by No_of_followers desc
limit 5)

select 
h.tag_name,
count(p.post_id) as Hashtag_Usage
from Top_5_influencers t
join posts p 
on p.user_id = t.user_id
join post_hashtags ph 
on ph.post_id = p.post_id
join hashtags h 
on h.hashtag_id = ph.hashtag_id
group by h.tag_name
order by Hashtag_Usage desc
limit 10;

/*Hastags used by the most users*/

select 
h.tag_name,
count(distinct ph.post_id) as Hashtag_Usage
from post_hashtags ph
join hashtags h
on h.hashtag_id = ph.hashtag_id
group by h.tag_name
order by Hashtag_Usage desc
limit 5;


/*
Engagment_Rate 
*/
select h.tag_name,
count(distinct ph.post_id) as Hashtag_Usage,
count(distinct l.like_id) as Total_likes,
count(distinct c.comment_id) as Total_comments,
count(distinct l.like_id) + 
count(distinct c.comment_id) as Total_Engagment_Rate
from post_hashtags ph
join hashtags h 
on ph.hashtag_id = h.hashtag_id
join  posts p
on p.post_id = ph.post_id
left join likes l
on l.post_id = p.post_id
left join comments c
on c.post_id = p.post_id
group by h.tag_name
order by Total_Engagment_Rate desc
limit 10;

/*
• Create a country-wise 
engagement leaderboard.
*/
with Total_comment_table as (select country,
count(p.post_id) as No_of_post,
count(like_id) as No_of_likes,
count(comment_id ) as No_of_comments
from users u
left join posts p
on u.user_id = p.user_id
left join likes l
on l.user_id = u.user_id
left join comments c
on c.user_id = u.user_id
group by country)

select country,
 No_of_post,
  No_of_likes,
  No_of_comments,
round((No_of_likes + No_of_comments)/nullif(No_of_post,0),2) as Engagement_rate ,
row_number() over( order by
round((No_of_likes + No_of_comments)/nullif(No_of_post,0),2) ) as Country_Rank
from Total_comment_table
order by Country_Rank ;

/*top 10  country-wise 
engagement leaderboard.*/

with Total_comment_table as (select country,
count(p.post_id) as No_of_post,
count(like_id) as No_of_likes,
count(comment_id ) as No_of_comments
from users u
left join posts p
on u.user_id = p.user_id
left join likes l
on l.user_id = u.user_id
left join comments c
on c.user_id = u.user_id
group by country)

select country,
 No_of_post,
  No_of_likes,
  No_of_comments,
round((No_of_likes + No_of_comments)/nullif(No_of_post,0),2) as Engagement_rate ,
row_number() over( order by
round((No_of_likes + No_of_comments)/nullif(No_of_post,0),2) ) as Country_Rank
from Total_comment_table
order by Country_Rank desc
limit 10 ;

DESC comments;
DESC  followers;
DESC  hashtags;
DESC   likes;
DESC post_hashtags;
DESC  posts;
DESC  users;


/*
Posting Hour Heatmap

*/
select 
hour(created_at) as Posting_Hour,
count(post_id) as Total_Posts
from posts p
group by hour(created_at)
order by Posting_Hour;

/*
Top 5 hours chart
*/

select 
hour(created_at) as Posting_Hour,
count(post_id) as Total_Posts
from posts 
group by hour(created_at)
order by Total_Posts desc
limit 5;

/*
Posting Activity by Weekday

*/
select 
dayname(created_at) as Posting_Day,
count(post_id) as Total_Posts
from posts 
group by dayname(created_at) , dayofweek(created_at)
order by Total_Posts asc;






/*KPI */

/*TOTAL users */

SELECT 
count(distinct u.user_id) as No_of_users,count(distinct comment_id) as No_of_comments,
count( distinct p.post_id) as No_of_post,count(distinct like_id) as No_of_likes
 from users u
 left join posts p
 on u.user_id = p.user_id
 left join comments c
 on u.user_id = c.user_id
 left join likes l
 on u.user_id = l.user_id;
 
 select count(user_id) as No_of_user
 from users;
 
 select count(like_id) as No_of_likes
from likes;

 select count(post_id) as No_of_post
from posts;

 SELECT 
    COUNT(comment_id) AS No_of_comment
FROM
    comments;


/*
Active User Rate = Users with ≥1 post OR 
like OR comment ÷ Total users × 100
*/

select count(*) Total_Customers,
	sum(
        case 	
				when exists(select 1
				from posts p
                where p.user_id = u.user_id)
                
                or exists (
                select 1
                from comments c
                where c.user_id = u.user_id
                )
                or exists (
                select 1
                from likes l 
                where l.user_id = u.user_id
                )
		then 1
        else 0
end
) as Active_Customers,

round(
  sum(
		case 
        when exists (
        select 1
        from posts p
        where p.user_id=u.user_id
		)
        or exists(
        select 1
        from likes l 
        where l.user_id = u.user_id
        )
        or exists (
        select 1
        from comments c 
        where c.user_id = u.user_id
        )
	then 1 
    else 0
    
end
  )/count(*) * 100,
      2

)as Active_User_Rate

from users u;




/*Inactive User %*/

select count(*) Total_Users,
	   sum( case 
				   when
				   not exists(
				   select 1
				   from posts p
				   where p.user_id = u.user_id
				   )
       and not exists
             (
				   select 1
				   from likes l
				   where l.user_id= u.user_id
				   )
	and not exists (
			   select 1
			   from comments c
			   where c.user_id = u.user_id
			   )
       then 1
       else 0
end
) as Total_No_Active_Users,

round(
sum(
case 
when 
not exists (
select 1
from posts p
where p.user_id = u.user_id
)
and
not exists(
select 1
from likes l
where l.user_id = u.user_id
)
and
not exists(
select 1
from comments c
where c.user_id = u.user_id

)
then 1
else 0
end
)/count(*)*100,2
) as Inactive_Engagment_Rate

from users u;



/*
   Users with no engagement rate (no posts)

   */
   
   ## Find users who have made 0 posts.
   
   select u.user_id,u.username
   from users u
   where  not exists (
   select 1
   from posts p
   where p.user_id = u.user_id);
   
   
   
   ## If you want the number of users with no posts:
   select count(*) as The_user_without_posts
   from users u
   where not exists (
   select 1
   from posts p
   where p.user_id = u.user_id
   );
   
   ##percentage
   select count(*) as Total_user_with_no_post,
   round(
   count(*)/(select count(*) from users )*100,2) as Percentage_of_user_with_no_post
   from users u
   where not exists (
   select 1
   from posts p
   where p.user_id = u.user_id);
   
   /*Users with zero likes + comments
*/

select count(*) as Total_user_with_no_comment_and_likes,
sum(
case 
when not exists 
(select 1
from likes l
where l.user_id = u.user_id)


and 
not exists (
select 1
from comments c
where c.user_id = u.user_id)

then 1
else 0
end
) as No_of_user_with_no_comments_and_likes,

round(
sum(
case 
when not exists 
(select 1
from likes l
where l.user_id = u.user_id)


and 
not exists (
select 1
from comments c
where c.user_id = u.user_id)

then 1
else 0
end
)/count(*)* 100,2

) as Percent_of_User_without_comments_and_likes

from users u;

/*User_with no likes*/
select count(*) as No_user_with_no_likes
from users u
where  not exists (
select 1
from likes l
where l.user_id = u.user_id
);

select count(*) as No_user_with_no_likes,

round(
count(*)/(select count(*) from users ) *100 , 2
) as Percentage_of_users_with_no_likes
from users u
where not exists (
select 1
from likes l
where l.user_id = u.user_id);

/*No. of users with no comments */
select count(*) as No_of_user_with_no_comments
from users u
where not exists (
select 1
from comments c
where c.user_id = u.user_id
);

select count(*) No_of_User_with_no_comments,
round(
count(*)/(select count(*) from users)*100,2) as Percentage_of_User_with_no_comments
from users u
where not exists (
select 1
from comments c
where c.user_id = u.user_id);

WITH followers_table AS (
    SELECT 
        username,
        u.user_id,
        COUNT(DISTINCT follower_user_id) AS No_of_followers
    FROM users u
    JOIN followers f 
        ON u.user_id = f.user_id
    GROUP BY username, u.user_id
    ORDER BY No_of_followers DESC
    LIMIT 5
)

SELECT 
    ft.username,
    h.tag_name,
    COUNT(p.post_id) AS No_Hashtags,

    ROUND(
        COUNT(p.post_id) * 100.0
        / SUM(COUNT(p.post_id)) OVER (PARTITION BY ft.user_id),
        2
    ) AS Usage_Rate;


