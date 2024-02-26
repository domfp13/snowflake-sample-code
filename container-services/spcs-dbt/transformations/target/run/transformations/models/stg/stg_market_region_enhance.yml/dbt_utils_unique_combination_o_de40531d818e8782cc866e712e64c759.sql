select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      





with validation_errors as (

    select
        COUNTRY_MARKET_REGION_ID, COUNTRY_ID, MARKET_REGION_NAME, SYS_UPDATE_TS
    from EDW_DEV.STG.stg_market_region_enhance
    group by COUNTRY_MARKET_REGION_ID, COUNTRY_ID, MARKET_REGION_NAME, SYS_UPDATE_TS
    having count(*) > 1

)

select *
from validation_errors



      
    ) dbt_internal_test