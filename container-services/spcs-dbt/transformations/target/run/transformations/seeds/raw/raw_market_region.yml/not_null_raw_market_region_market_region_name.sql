select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select market_region_name
from EDW_DEV.RAW.raw_market_region
where market_region_name is null



      
    ) dbt_internal_test