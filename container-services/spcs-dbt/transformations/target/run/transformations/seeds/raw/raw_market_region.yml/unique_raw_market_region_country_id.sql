select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    country_id as unique_field,
    count(*) as n_records

from EDW_DEV.RAW.raw_market_region
where country_id is not null
group by country_id
having count(*) > 1



      
    ) dbt_internal_test