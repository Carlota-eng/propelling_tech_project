{{
    config(
        materialized='table'
    )
}}

SELECT 
    n_nationkey,
    n_name,
    n_regionkey,
    n_comment,
    CURRENT_TIMESTAMP() as dbt_loaded_at
FROM {{ source('tpch_source', 'nation') }}