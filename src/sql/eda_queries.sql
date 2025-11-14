use project_a_db;
-- ######################################################################
-- Q1: 观察各表的缺失值和异常值情况，并进行初步清洗/筛选门槛的确定
-- ######################################################################
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
-- Q1.3, 财务: 设置budget异常值的清洗门槛，运行下面的代码得到不同区间内的budget条目数
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

-- Q1.4, 财务: 设置revenue异常值的清洗门槛，运行下面的代码得到不同区间内的budget值正常情况下的revenue条目数
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

-- Q1.5, 评分: 设置评分人数的筛选门槛，先观察设置为20与50时分别会筛去多少数据
select
	count(*) as total_rows,
    sum(case when vote_count < 20  then 1 else 0 end) as v_twenty_count,
    sum(case when vote_count < 20  then 1 else 0 end)/count(*) as v_twenty_percent,
    sum(case when vote_count < 50 then 1 else 0 end) as v_fifty_count,
    sum(case when vote_count < 50 then 1 else 0 end)/count(*) as v_fifty_percent
from tmdb_movies
-- --------------------------------------------------------------------------

-- 这与budget、revenue的清洗不同，后者在物理上就是不真实的，所以设为NULL
-- 而评分人数在物理上是真实的，只是人数过少可能不能反映电影的受欢迎程度，我们只需要筛选出可靠的即可
-- 有24%的数据评分人数小于50，这是个可以接受的损失。我们以 vote_count >= 50 为筛选门槛
/*
-- Q1.x, 评分: 最高/低评分
select
	max(vote_average) as max_rating,
    min(vote_average) as min_rating
from tmdb_movies
where vote_count >= 50;
*/
-- Q1.6, 财务: 确认ROI（投资回报率，Return on Investment）分析的规模
SET @total_movies = 4803; 
SELECT
    COUNT(CASE WHEN budget IS NOT NULL AND revenue IS NOT NULL THEN 1 END) AS count_gt_10k_movies,
    ROUND(100.0 * (COUNT(*) - COUNT(CASE WHEN budget IS NOT NULL AND revenue IS NOT NULL THEN 1 END)) / @total_movies, 2) AS missing_percent_gt_10k
FROM
    tmdb_movies;
-- --------------------------------------------------------------------------

-- 有3205行数据可用于ROI分析

-- ######################################################################
-- Q2, 财务: 分析ROI，有多少电影盈利？多少电影亏损？按照国家来区分呢？
-- ######################################################################
-- Q2.1: 创建ROI表
SET @movie_count = 3205; -- ROI分析有效数据
create table tmdb_ROI as (
select
    movie_id,
    cast((revenue / budget) as double) as ROI_Value
from
    tmdb_movies
where 
    budget is not null and revenue is not null
order by ROI_value);

-- Q2.2: 计算ROI及其均值、中位数、异常值，等等
with T_ranked as (
	select
		ROI_value,
		row_number() over (order by ROI_value) as rown,
        count(*) as total_count -- 不用@movie_count的原因是避免之后只对某个类型/国家/评分的作where筛选的情况
	from tmdb_ROI)
select
    -- ROI 均值
    avg(ROI_value) as ROI_Mean,
    -- ROI 中位数
    -- (select T.ROI_value from T_ranked T
    --  where T.rown = (T.total_count + 1) / 2) AS ROI_Median,
    -- ROI 异常值计数 (Anomaly Count) - 找出 ROI 大于 100 和小于 0.01 的电影数量
    SUM(CASE WHEN ROI_value >= 100 THEN 1 ELSE 0 END) AS ROI_gt_100_Count,
    SUM(CASE WHEN ROI_value <= 0.01 THEN 1 ELSE 0 END) AS ROI_lt_1perc_Count,
    -- 常说的电影行业中有一个盈利2.5倍法则——对于大成本电影，当ROI达到2.5左右时，电影才不至于亏本
    SUM(CASE WHEN ROI_value > 2 and ROI_value < 3 THEN 1 ELSE 0 END)/@movie_count AS make_ends_percent,
    SUM(CASE WHEN ROI_value < 2.5 THEN 1 ELSE 0 END)/@movie_count AS normal_percent,
    SUM(CASE WHEN ROI_value > 2.5 THEN 1 ELSE 0 END)/@movie_count AS success_percent,
    SUM(CASE WHEN ROI_value > 10 THEN 1 ELSE 0 END)/@movie_count AS bigsuccess_percent,
    -- 核心数据集大小 (用于最终确认)
    @movie_count AS Total_Analyzed_Movies
FROM
    tmdb_ROI;




-- Q3: 一个演员参与更多亏损的影片的话，在样本足够的情况下，是否意味着他的能力可能更差，从而电影的预算可能更低？如何来评判这一点，如何考虑相关性？
-- Q4: 我可以对导演或是制片或是其他的幕后人员做同样的提问，这两个情况下哪一种相关性会更大？尤其，我想要关注导演和编剧。








# 评分人数应设置50为最小门槛吗？

# 以及亏本和回本的电影各有多少；
