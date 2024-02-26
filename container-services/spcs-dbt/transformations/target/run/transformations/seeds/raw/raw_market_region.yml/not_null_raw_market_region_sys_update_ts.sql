select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select sys_update_ts
from EDW_DEV.RAW.raw_market_region
where sys_update_ts is null



      
    ) dbt_internal_test