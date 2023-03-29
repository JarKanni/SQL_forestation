--DROP VIEW to fix Udacity workspace error
DROP VIEW IF EXISTS forestation; 

--forestation VIEW used for further analysis
CREATE VIEW forestation 
AS (
SELECT f.country_code c_code
    , f.country_name
    , r.region
    , r.income_group
    , f.year
    , ROUND(f.forest_area_sqkm::numeric, 2) forest_area_sqkm
    , ROUND((f.forest_area_sqkm / 2.59)::numeric, 2) AS forest_area_sq_mi
    , ROUND(l.total_area_sq_mi::numeric, 2) total_area_sq_mi
    , ROUND((((f.forest_area_sqkm / 2.59) / total_area_sq_mi) * 100)::numeric, 2) AS total_percent_forest
FROM forest_area f
JOIN land_area l
	ON f.year = l.year AND  f.country_code = l.country_code
JOIN regions r
ON r.country_code = l.country_code
);

--------------------------------------------------

--subqueries
    --find total forest area of world in 1990
WITH world_forest_area_1990 AS (
            SELECT SUM(forest_area_sq_mi) total
            FROM forestation
            WHERE year = '1990'
            )
    --find total forest area of world in 2016      
    , world_forest_area_2016 AS (
            SELECT SUM(f.forest_area_sq_mi) total
            FROM forestation f
            WHERE year = '2016'
            )
    --find total area of world in 2016
    , world_area_2016 AS (
            SELECT l.total_area_sq_mi total
            FROM land_area l
            WHERE country_name = 'World' AND year = '2016'
            )
    --find total percent of world designated as forest in 1990
    , percent_forest_1990 AS (
            SELECT f.region
                , ROUND((SUM(f.forest_area_sq_mi) / SUM(f.total_area_sq_mi)*100)::numeric, 2) percent_forest_1990
            FROM forestation f
            WHERE 1=1
                AND f.total_percent_forest IS NOT NULL
                AND year = '1990'
                AND region LIKE 'World'
            GROUP BY 1
            ORDER BY 2 DESC
            )
    --find total percent of world designated as forest in 2016
    , percent_forest_2016 AS (
            SELECT f.region
                , ROUND((SUM(f.forest_area_sq_mi) / SUM(f.total_area_sq_mi)*100)::numeric, 2) percent_forest_2016
            FROM forestation f
            WHERE 1=1
                AND f.total_percent_forest IS NOT NULL
                AND year = '2016'
                AND region LIKE 'World'
            GROUP BY 1
            ORDER BY 2 DESC
            )
    --finds 1990 forest area totals by country
    , forest_percent_1990 AS (
            SELECT f.country_name
                , ROUND((SUM(f.forest_area_sq_mi) / SUM(f.total_area_sq_mi)*100)::numeric, 2) percent_total_1990
            FROM forestation f
            WHERE 1=1
                AND f.total_percent_forest IS NOT NULL
                AND year = '1990'
                AND region NOT LIKE 'World'
            GROUP BY 1
            ORDER BY 2 DESC
            )
    --finds 2016 forest area totals by country
    , forest_percent_2016 AS (
                SELECT f.country_name
                , ROUND((SUM(f.forest_area_sq_mi) / SUM(f.total_area_sq_mi)*100)::numeric, 2) percent_total_2016
            FROM forestation f
            WHERE 1=1
                AND f.total_percent_forest IS NOT NULL
                AND year = '2016'
                AND region NOT LIKE 'World'
            GROUP BY 1
            ORDER BY 2 DESC
            )

    --finds 1990 forest area totals by country
    ,  forest_area_1990 AS (
            SELECT f.country_name
				, f.forest_area_sq_mi f_area_1990
			FROM forestation f
			WHERE 1=1
				AND f.total_percent_forest IS NOT NULL
				AND year = '1990'
				AND country_name NOT LIKE 'World'
			ORDER BY 2 DESC
            )
    --finds 2016 forest area totals by country
	, forest_area_2016 AS (
            SELECT f.country_name
				, f.forest_area_sq_mi f_area_2016
			FROM forestation f
			WHERE 1=1
				AND f.total_percent_forest IS NOT NULL
				AND year = '2016'
				AND country_name NOT LIKE 'World'
			ORDER BY 2 DESC
            )


/* 1. Global Situtaion */

--main query to find total loss from 1990 to 2016
SELECT forest_area_1990
	, forest_area_2016
    , forest_area_1990.total - forest_area_2016.total total_loss
    , round(((forest_area_1990.total - forest_area_2016.total) / forest_area_1990.total)*100::numeric, 2) total_loss_percent
FROM forest_area_1990, forest_area_2016
;

--find country whose total_area_sq_mi roughly equals the total area of deforesation
SELECT l.country_name
	, l.total_area_sq_mi
FROM land_area l
WHERE total_area_sq_mi BETWEEN 334000 AND 350000
GROUP BY 1, 2
ORDER BY 2 DESC
;

--------------------------
/* 2. Regional Outlook */

--2016: total percent forest coverage of the world 
SELECT f.region
    , ROUND((SUM(f.forest_area_sq_mi) / SUM(f.total_area_sq_mi)*100)::numeric, 2) percent_total
FROM forestation f
WHERE 1=1
	AND f.total_percent_forest IS NOT NULL
    AND year = '2016'
    AND region LIKE 'World'
GROUP BY 1
ORDER BY 2 DESC
;

--2016: region with highest/lowest (remove DESC) forest percentages
SELECT f.region
    , ROUND((SUM(f.forest_area_sq_mi) / SUM(f.total_area_sq_mi)*100)::numeric, 2) percent_total
FROM forestation f
WHERE 1=1
	AND f.total_percent_forest IS NOT NULL
    AND year = '2016'
    AND region NOT LIKE 'World'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1
;

--1990: total percent forest coverage of the world
SELECT f.region
    , ROUND((SUM(f.forest_area_sq_mi) / SUM(f.total_area_sq_mi)*100)::numeric, 2) percent_total
FROM forestation f
WHERE 1=1
	AND f.total_percent_forest IS NOT NULL
    AND year = '1990'
    AND region LIKE 'World'
GROUP BY 1
ORDER BY 2
LIMIT 1
;

--1990: region with highest/lowest (remove DESC) forest percentages
SELECT f.region
    , ROUND((SUM(f.forest_area_sq_mi) / SUM(f.total_area_sq_mi)*100)::numeric, 2) percent_total
FROM forestation f
WHERE 1=1
	AND f.total_percent_forest IS NOT NULL
    AND year = '1990'
    AND region NOT LIKE 'World'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1
;

--compare for only 'World' percent_forest_1990 and percent_forest_2016
SELECT *
FROM percent_forest_1990 p1990
INNER JOIN percent_forest_2016 p2016
	ON p1990.region = p2016.region 
;

--------------------------
/* 3. Country Level */

--A. Success Stories
--compare total forest area change by country between 1990 and 2016
SELECT f1990.country_name
	, f1990.f_area_1990
	, f2016.f_area_2016
	, f2016.f_area_2016 - f1990.f_area_1990 area_change
	, ROUND((((f2016.f_area_2016 - f1990.f_area_1990) / f2016.f_area_2016)*100)::numeric, 2) percent_change
FROM forest_area_1990 f1990
JOIN forest_area_2016 f2016
	ON f1990.country_name = f2016.country_name
GROUP BY 1, 2, 3
ORDER BY 4 DESC
;

--find top two countries with largest land area
SELECT country_name
	, total_area_sq_mi
FROM forestation f
WHERE 1=1
	AND total_area_sq_mi IS NOT NULL
    AND country_name NOT LIKE 'World'
    AND year = '2016'
GROUP BY 1, 2
ORDER BY 2 DESC
LIMIT 2
;

--compare total forest acre change between 1990 and 2016
SELECT f2016.country_name
 	, round((forest_area_2016 - forest_area_1990)::numeric, 2) area_change
    , round((((forest_area_2016 - forest_area_1990) / f.total_area_sq_mi)*100)::numeric, 2) percent_change
 FROM forestation f, forest_area_2016 f2016
 JOIN forest_area_1990 f1990
 	ON f1990.country_name = f2016.country_name
 GROUP BY 1, 2, 3
 ORDER BY 2 DESC;

--compare percent change in forest area by country between 1990 and 2016
SELECT f1990.country_name
	, f1990.percent_total_1990
	, f2016.percent_total_2016
	, (percent_total_2016 - percent_total_1990) change
FROM forest_percent_1990 f1990
JOIN forest_percent_2016 f2016
	ON f1990.country_name = f2016.country_name
GROUP BY 1, 2, 3, 4
ORDER BY change DESC;

--B. Largest Concerns
--finds percent change by country
SELECT f1990.country_name
	, r.region
	, f1990.f_area_1990
	, f2016.f_area_2016
	, f2016.f_area_2016 - f1990.f_area_1990 area_change
	, ROUND((((f2016.f_area_2016 - f1990.f_area_1990) / f1990.f_area_1990)*100)::numeric, 2) percent_change
FROM forest_area_1990 f1990
JOIN forest_area_2016 f2016
	ON f1990.country_name = f2016.country_name
JOIN regions r
	ON f1990.country_name = r.country_name
GROUP BY 1, 2, 3, 4
ORDER BY 6
;

--count of countries grouped by total_percent_forest for 2016
SELECT
	CASE
		WHEN f.total_percent_forest > 75 THEN '4th Quartile'
		WHEN f.total_percent_forest > 50 AND f.total_percent_forest < 75 THEN '3rd Quartile'
		WHEN f.total_percent_forest > 25 AND f.total_percent_forest < 50 THEN '2nd Quartile'
		ELSE '1st Quartile' END AS quartiles
	, COUNT(*) AS count
FROM forestation f
WHERE year = '2016'
GROUP BY 1
ORDER BY 1
;

--top quartile countries 2016
SELECT f.country_name
	, f.region
	, f.total_percent_forest
FROM forestation f
WHERE 1=1
	AND f.year = '2016'
	AND f.total_percent_forest IS NOT NULL
ORDER BY 3 DESC
;