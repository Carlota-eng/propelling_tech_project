{{
    config(
        materialized='incremental',
        unique_key='c_custkey'
    )
}}

SELECT 
    c_custkey,
    c_name,
    c_address,
    c_nationkey,
    c_phone,
    c_acctbal,
    c_mktsegment,
    c_comment,
    CURRENT_TIMESTAMP() as dbt_loaded_at
FROM {{ source('tpch_source', 'customer') }}

{% if is_incremental() %}
    WHERE c_custkey > (SELECT COALESCE(MAX(c_custkey), 0) FROM {{ this }})
{% endif %}