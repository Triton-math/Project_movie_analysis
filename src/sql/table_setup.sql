create database project_a_db;
use project_a_db;
# 用于删除表格
# drop table tmdb_staffs, tmdb_movies;
# 建立表格
create table tmdb_staffs (
	movie_id int primary key,
    title varchar(100),
    cast text,
    crew text
);
# id, title, production_countries, revenue, budget, vote_average, vote_count
create table tmdb_movies (
	movie_id int primary key,
    title varchar(100),
    country text,
    revenue bigint,
    budget bigint,
    vote_average double,
    vote_count int
);