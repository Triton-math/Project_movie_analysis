use project_a_db;
-- Q1: 观察各表的缺失值和异常值情况
-- Q1.1: 对staffs表观察缺失值
select
	count(*) as total_rows,
    sum(case when title is null then 1 else 0 end) as missing_title_rows,
    sum(case when cast is null then 1 else 0 end) as missing_cast_rows,
    sum(case when crew is null then 1 else 0 end) as missing_crew_rows
from tmdb_staffs;
-- Q1.2: 对movies表观察缺失值
select
	count(*) as total_rows,
    sum(case when title is null then 1 else 0 end) as missing_title_rows,
    sum(case when country is null then 1 else 0 end) as missing_country_rows,
    sum(case when revenue is null then 1 else 0 end) as missing_revenue_rows,
    sum(case when budget is null then 1 else 0 end) as missing_budget_rows,
    sum(case when vote_average is null then 1 else 0 end) as missing_vote_average_rows,
    sum(case when vote_count is null then 1 else 0 end) as missing_vote_count_rows
from tmdb_movies;
-- --------------------------------------------------------------------------

-- 没有缺失值，分析设置budget异常值的清洗门槛
-- Q1.3: 设置budget异常值的清洗门槛，运行下面的代码得到不同区间内的budget条目数
select
	count(*) as total_rows,
    sum(case when budget = 0 then 1 else 0 end) as zero_budget_count,
    sum(case when budget = 0 then 1 else 0 end)/count(*) as zero_budget_percent,
    sum(case when budget < 1000 then 1 else 0 end) - sum(case when budget = 0 then 1 else 0 end) as thousand_budget_count,
    sum(case when budget < 1000 then 1 else 0 end)/count(*) as thousand_budget_percent,
    sum(case when budget < 10000 then 1 else 0 end) - sum(case when budget < 1000 then 1 else 0 end) as tenthousand_budget_count,
    sum(case when budget < 10000 then 1 else 0 end)/count(*) as tenthousand_budget_percent,
    sum(case when budget < 100000 then 1 else 0 end) - sum(case when budget < 10000 then 1 else 0 end) as hundredthousand_budget_count,
    sum(case when budget < 100000 then 1 else 0 end)/count(*) as hundredthousand_budget_percent
from tmdb_movies;
-- --------------------------------------------------------------------------

-- budget < 1000不符合实际，应作为缺失值舍去
-- 1000 <= budget < 10000区间内只有3个数据，作为噪音数据排除
-- 10000<= budget < 100000区间内有23个数据，可以相信
-- 我们确定 budget = 10000 为清洗门槛，将低于此门槛的值设为 NULL。请确保在运行任何分析之前运行此 UPDATE 语句。
-- 注意要禁用safe update mode，客户端edit->preferences->sql editor->取消勾选 safe updates
update tmdb_movies
set budget = null
where budget < 10000;

-- Q1.4: 设置revenue异常值的清洗门槛，运行下面的代码得到不同区间内的budget值正常情况下的revenue条目数
select
	count(*) as total_rows,
    sum(case when revenue = 0 then 1 else 0 end) as zero_count,
    sum(case when revenue = 0 then 1 else 0 end)/count(*) as zero_percent,
    sum(case when revenue < 1000 then 1 else 0 end) - sum(case when revenue = 0 then 1 else 0 end) as thousand_count,
    sum(case when revenue < 1000 then 1 else 0 end)/count(*) as thousand_percent,
    sum(case when revenue < 10000 then 1 else 0 end) - sum(case when revenue < 1000 then 1 else 0 end) as tenthousand_count,
    sum(case when revenue < 10000 then 1 else 0 end)/count(*) as tenthousand_percent,
    sum(case when revenue < 100000 then 1 else 0 end) - sum(case when revenue < 10000 then 1 else 0 end) as hundredthousand_count,
    sum(case when revenue < 100000 then 1 else 0 end)/count(*) as hundredthousand_percent,
    sum(case when revenue < 1000000 then 1 else 0 end) - sum(case when revenue < 100000 then 1 else 0 end) as million_count,
    sum(case when revenue < 1000000 then 1 else 0 end)/count(*) as million_percent
from tmdb_movies
where budget is not null;
-- --------------------------------------------------------------------------

-- revenue < 1000不符合实际，应作为缺失值舍去
-- 1000 <= revenue < 10000区间内有4个数据，作为噪音数据排除
-- 10000<= revenue < 100000区间内有35个数据，可以相信
-- 我们确定 revenue = 10000 为清洗门槛，将低于此门槛的值设为 NULL。请确保在运行任何分析之前运行此 UPDATE 语句。
update tmdb_movies
set revenue = null
where revenue < 10000;

-- Q1.5











# 评分人数应设置50为最小门槛吗？

# 以及亏本和回本的电影各有多少；
