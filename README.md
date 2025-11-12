# 🎬 电影投资风险与盈利能力分析（TMDB 5000 Dataset）

本项目旨在通过分析电影的预算、票房、演职人员和评分数据，评估不同电影的投资回报率（ROI）和人才的商业价值。

---

## 🎯 核心业务问题 (Business Questions)

1.  **数据清洗与完整性：** 在设定合理的商业门槛后，有多少电影具备可靠的财务数据，并检查数据中的逻辑异常（如“有票房无预算”）。
2.  **盈利能力分析 (ROI)：** 哪些制片国家/地区的投资回报率（ROI）最高？
3.  **人才风险评估：** 演员或导演参与亏损影片的比例，是否与其后续参演影片的预算和票房存在负相关性？
4.  **制片策略评估：** 评分与票房是否存在正相关性？
5.  *TBA*

---

## 🛠️ 项目技术栈 (Tech Stack)

* **数据摄取/清洗：** Python 3.x, Pandas
* **数据库/查询：** MySQL
* **可视化/统计分析 (Block 2):** TBA
* **版本控制：** Git

---

## 📊 数据源和数据挑战 (Data Source & Challenges)

### 数据源

* **名称:** TMDB 5000 Movie Dataset
* **来源:** Kaggle
* **链接:** [https://www.kaggle.com/datasets/tmdb/tmdb-movie-metadata/data](https://www.kaggle.com/datasets/tmdb/tmdb-movie-metadata/data)

### 关键数据挑战

本项目的主要挑战是 **原始财务数据的高噪音和不准确性**：

* **脏数据处理：** 原始 `budget` 和 `revenue` 字段存在大量微小/错误值（如 $1、10、7000$）。
* **鲁棒性策略：** 我们采取了**商业门槛清洗法**，将 $\text{budget} \le 1000$ 的数据统一标准化为 $\text{NULL}$，以保障后续 $\text{ROI}$ 分析的鲁棒性。
* **JSON 解析：** 需要使用 $\text{SQL}$ 或 $\text{Pandas}$ 解析 `genres`, `cast`, `crew` 等复杂 $\text{JSON}$ 字符串。

---

## 📂 项目结构 (Project Structure)
```
Project_movie_analysis/
├── data/
│   └── raw/              # 原始 CSV 文件（已加入 .gitignore，不上传至 GitHub）
├── src/                  # 核心源代码
│   ├── python/           # Python 脚本
│   │   ├── proj_ingestion.py   # 数据导入、清洗和 ETL 逻辑
│   │   └── visualization.py        # 基于 SQL 结果的可视化分析脚本
│   └── sql/              # SQL 脚本
│       ├── table_setup.sql         # 数据库和表结构定义（CREATE TABLE 语句）
│       └── eda_queries.sql         # 探索性数据分析（EDA）查询集合
├── .gitignore            # Git 忽略文件配置（忽略 .env, /data/raw/ 等）
└── README.md             # 项目说明和入口文件
```
---

## 💻 如何运行项目 (Setup & Run)

1.  **克隆仓库：** `git clone [您的仓库URL]`
2.  **环境配置：** 创建 Python 虚拟环境并安装依赖（pandas, sqlalchemy, pymysql, dotenv）。
3.  **数据库设置：** 配置Mysql的连接参数，在 MySQL Workbench 中运行 `src/sql/table_setup.sql` 建立表结构。
4.  **数据导入：** 将Mysql连接参数的相关信息存储到一个新建的.env文件中并放置在根目录下，运行 Python 脚本导入数据：`python src/python/proj_ingestion.py`