





with validation_errors as (

    select
        COUNTRY_MARKET_REGION_ID, COUNTRY_ID, MARKET_REGION_NAME, SYS_UPDATE_TSSYS_UPDATE_TS
    from EDW_DEV.raw_stg.stg_market_region
    group by COUNTRY_MARKET_REGION_ID, COUNTRY_ID, MARKET_REGION_NAME, SYS_UPDATE_TSSYS_UPDATE_TS
    having count(*) > 1

)

select *
from validation_errors


