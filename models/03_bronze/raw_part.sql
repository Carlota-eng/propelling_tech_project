{{
    config(
        materialized='incremental',
        unique_key='p_partkey'
    )
}}

SELECT 
    p_partkey,
    p_name,
    p_mfgr,
    p_brand,
    p_type,
    p_size,
    p_container,
    p_retailprice,
    p_comment,
    CURRENT_TIMESTAMP() as dbt_loaded_at
FROM {{ source('tpch_source', 'part') }}

{% if is_incremental() %}
    WHERE p_partkey > (SELECT COALESCE(MAX(p_partkey), 0) FROM {{ this }})
{% endif %}