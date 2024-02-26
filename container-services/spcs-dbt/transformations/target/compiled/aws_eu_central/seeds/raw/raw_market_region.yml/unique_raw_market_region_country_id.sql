
    
    

select
    country_id as unique_field,
    count(*) as n_records

from EDW_DEV.RAW_raw.raw_market_region
where country_id is not null
group by country_id
having count(*) > 1


