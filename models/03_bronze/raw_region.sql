{{
    config(
        materialized='table'
    )
}}

SELECT 
    r_regionkey,
    r_name,
    r_comment,
    CURRENT_TIMESTAMP() as dbt_loaded_at
FROM {{ source('tpch_source', 'region') }}