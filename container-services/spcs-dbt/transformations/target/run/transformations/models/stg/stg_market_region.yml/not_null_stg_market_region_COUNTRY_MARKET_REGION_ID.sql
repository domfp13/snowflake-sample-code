select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select COUNTRY_MARKET_REGION_ID
from EDW_DEV.STG.stg_market_region
where COUNTRY_MARKET_REGION_ID is null



      
    ) dbt_internal_test