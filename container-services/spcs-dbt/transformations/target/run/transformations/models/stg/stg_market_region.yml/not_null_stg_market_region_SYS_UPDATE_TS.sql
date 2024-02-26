select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select SYS_UPDATE_TS
from EDW_DEV.STG.stg_market_region
where SYS_UPDATE_TS is null



      
    ) dbt_internal_test