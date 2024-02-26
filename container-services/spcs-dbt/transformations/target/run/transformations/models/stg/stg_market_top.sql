

      create or replace transient table EDW_DEV.STG.stg_market_top  as
      (
WITH  __dbt__cte__stg_market_ephemeral_one as (

WITH LINEAGE AS (
    SELECT * FROM EDW_DEV.STG.stg_market_region_enhance
)
SELECT MARKET_REGION_NAME, COUNT(*) AS NUMBER_REGION
FROM LINEAGE
GROUP BY MARKET_REGION_NAME
HAVING COUNT(*)>4
),  __dbt__cte__stg_market_ephemeral_two as (

WITH LINEAGE AS (
    SELECT * FROM EDW_DEV.STG.stg_market_region_enhance
)
SELECT MARKET_REGION_NAME, COUNT(*) AS NUMBER_REGION
FROM LINEAGE
GROUP BY MARKET_REGION_NAME
HAVING COUNT(*)<=4
),EPHEMERAL_ONE AS (
    SELECT * FROM __dbt__cte__stg_market_ephemeral_one
),
EPHEMERAL_TWO AS (
    SELECT * FROM __dbt__cte__stg_market_ephemeral_two
)
SELECT * 
FROM (
  SELECT *
  FROM EPHEMERAL_ONE
  UNION ALL
  SELECT *
  FROM EPHEMERAL_TWO
)
ORDER BY NUMBER_REGION
      );
    