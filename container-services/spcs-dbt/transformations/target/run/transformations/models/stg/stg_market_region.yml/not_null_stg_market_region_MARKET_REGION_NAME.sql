select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select MARKET_REGION_NAME
from EDW_DEV.STG.stg_market_region
where MARKET_REGION_NAME is null



      
    ) dbt_internal_test