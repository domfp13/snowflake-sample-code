select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select country_id
from EDW_DEV.RAW.raw_market_region
where country_id is null



      
    ) dbt_internal_test