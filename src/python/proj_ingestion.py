import pandas as pd
from sqlalchemy import create_engine
import pymysql # 导入 pymysql 驱动
import os
from dotenv import load_dotenv

load_dotenv()  # 从 .env 文件加载环境变量

# --- 1. 配置数据库连接参数 ---
# 请将这些参数替换为您 MySQL Workbench 的连接信息
USER = os.getenv('DB_USER')
PASSWORD = os.getenv('DB_PASSWORD') 
HOST = os.getenv('DB_HOST')
DATABASE = os.getenv('DB_DATABASE')

# --- 2. 创建数据库连接引擎 ---
# 注意：使用 mysql+pymysql 格式连接
try:
    engine = create_engine(f'mysql+pymysql://{USER}:{PASSWORD}@{HOST}/{DATABASE}')
except Exception as e:
    print(f"数据库连接失败，请检查参数和 pymysql 安装: {e}")
    # 您可能需要先在 MySQL Workbench 中创建一个名为 project_a_db 的数据库
    exit()

# --- 3. 读取 CSV 文件 (使用容错编码) ---
CSV_FILE_PATH1 = './data/raw/tmdb_5000_credits.csv' # 请确保路径正确
CSV_FILE_PATH2 = './data/raw/tmdb_5000_movies.csv' # 请确保路径正确

try:
    # 尝试最常见的 UTF-8 编码
    df1 = pd.read_csv(CSV_FILE_PATH1, encoding='utf-8')
    print(f"表一有{len(df1)}行")
    df2 = pd.read_csv(CSV_FILE_PATH2, encoding='utf-8')
    print(f"表二有{len(df2)}行")
except UnicodeDecodeError:
    # 如果 UTF-8 失败，尝试 Latin1 (对于非标准/旧系统编码很有效)
    print("UTF-8 编码失败，尝试 Latin1...")
    df1 = pd.read_csv(CSV_FILE_PATH1, encoding='latin1') 
    df2 = pd.read_csv(CSV_FILE_PATH2, encoding='latin1') 

# --- 4. 导入数据到 SQL 表 ---
TABLE_NAME1 = 'tmdb_staffs'
COLUMNS_TO_KEEP1 = ['movie_id', 'title', 'cast', 'crew']
TABLE_NAME2 = 'tmdb_movies'
COLUMNS_TO_KEEP2 = ['id','budget', 'production_countries', 'revenue', 'title', 'vote_average', 'vote_count']
df1=df1[COLUMNS_TO_KEEP1]
df2=df2[COLUMNS_TO_KEEP2]
rename_map = {
    'id': 'movie_id',
    'production_countries': 'country',
}
df2.rename(columns=rename_map, inplace=True)

'''
这一段代码是用来检验各行最大值的，以后可以以此分析数据类型要如何赋予
max_len_data1 = df2['revenue'].astype(str).str.len().max()
max_len_data2 = df2['budget'].astype(str).str.len().max()
max_len_data3 = df2['vote_average'].astype(str).str.len().max()
max_len_data4 = df2['vote_count'].astype(str).str.len().max()
print(f"DataFrame中'revenue'列的最大长度是: {max_len_data1}")
print(f"DataFrame中'budget'列的最大长度是: {max_len_data2}")
print(f"DataFrame中'vote_average'列的最大长度是: {max_len_data3}")
print(f"DataFrame中'vote_count'列的最大长度是: {max_len_data4}")
'''

try:
    print(f"开始导入 {len(df1)} 与 {len(df2)} 行数据到 MySQL...")
    # if_exists='append'：将数据追加到现有表，index=False：不导入 Pandas 索引
    df1.to_sql(name=TABLE_NAME1, con=engine, if_exists='append', index=False, chunksize=1000)
    df2.to_sql(name=TABLE_NAME2, con=engine, if_exists='append', index=False, chunksize=1000)
    
    print(f"🎉 导入成功! 总行数: {len(df1)} 与 {len(df2)}")
    
except Exception as e:
    print(f"导入到 SQL 失败: {e}")

