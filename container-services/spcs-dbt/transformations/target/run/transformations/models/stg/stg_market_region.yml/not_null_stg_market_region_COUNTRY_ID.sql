select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select COUNTRY_ID
from EDW_DEV.STG.stg_market_region
where COUNTRY_ID is null



      
    ) dbt_internal_test