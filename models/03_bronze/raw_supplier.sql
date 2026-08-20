{{
    config(
        materialized='incremental',
        unique_key='s_suppkey',
        strategy='merge'
    )
}}

SELECT 
    s_suppkey,
    s_name,
    s_address,
    s_nationkey,
    s_phone,
    s_acctbal,
    s_comment,
    CURRENT_TIMESTAMP() AS RAW_LOADED_AT
FROM {{ source('tpch_source', 'supplier') }}

{% if is_incremental() %}
    WHERE s_suppkey > (SELECT COALESCE(MAX(s_suppkey), 0) FROM {{ this }})
{% endif %}