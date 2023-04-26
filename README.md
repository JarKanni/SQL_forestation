# SQL_forestation
Data analysis using SQL queries on three .csv files loaded into Postgres.
Utitlizing 'forestation' VIEW, the analysis split between the Global, Regional, and Country levels to look at total forest coverage and change between 1990 and 2016.

# Description
- Loaded three .csv files into Postgres database tables
- Created "forestation" VIEW with custom aggrigated columns joining three tables using SQL
- Explored multiple statistical SQL queries utiltizing JOINs and aggregations to drill deep into the data


# Requirements
Three database Tables (with columns) named:
- forest_area
    - country_code
    - country_name
    - year
    - forest_area_sqkm
- land_area
    - country_code
    - country_name
    - year
    - total_area_sq_mi
- regions
    - country_name
    - country_code
    - region
    - income_group

Ability to run SQL queries on a database:
  - PostgresSQL, for example


# Installation
- Install database server such as: <a href="https://www.postgresql.org/download/">PostgresSQL</a>
- Load three .csv files into database tables.
- Run SQL queries and discover what's there!


# Contact Information
**Name:** Jared R. Kannianen

**Organization:** Masterschool - Data Analyst

**Email:** jarkanni@campus.masterschool.com
