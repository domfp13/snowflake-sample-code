
-- https://docs.getdbt.com/reference/resource-configs/pre-hook-post-hook
WITH LINEAGE AS (
    SELECT * FROM EDW_DEV.STG.stg_market_region
)
SELECT *
FROM EDW_DEV.STG.stg_market_region_enhance