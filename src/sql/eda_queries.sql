use project_a_db;

# 对staffs表观察缺失值
select
	count(*) as total_rows,
    sum(case when title is null then 1 else 0 end) as missing_title_rows,
    sum(case when cast is null then 1 else 0 end) as missing_cast_rows,
    sum(case when crew is null then 1 else 0 end) as missing_crew_rows
from tmdb_staffs;

# 对movies表观察缺失值
select
	count(*) as total_rows,
    sum(case when title is null then 1 else 0 end) as missing_title_rows,
    sum(case when country is null then 1 else 0 end) as missing_country_rows,
    sum(case when revenue is null then 1 else 0 end) as missing_revenue_rows,
    sum(case when budget is null then 1 else 0 end) as missing_budget_rows,
    sum(case when vote_average is null then 1 else 0 end) as missing_vote_average_rows,
    sum(case when vote_count is null then 1 else 0 end) as missing_vote_count_rows
from tmdb_movies;

# 对movies表中budget, revenue, vote_average, vote_count观察异常值；以及亏本和回本的电影各有多少；
select
	count(*) as total_rows,
    sum(case when revenue = 0 then 1 else 0 end) as zero_revenue_rows,
    sum(case when budget = 0 then 1 else 0 end) as zero_budget_rows,
    sum(case when vote_average = 0 then 1 else 0 end) as zero_vote_average_rows,
    sum(case when vote_count = 0 then 1 else 0 end) as zero_vote_count_rows,
    sum(case when (revenue < 0 or budget < 0 or (vote_count = 0 and vote_average !=0)) then 1 else 0 end) as strange_revenue_rows
from tmdb_movies;