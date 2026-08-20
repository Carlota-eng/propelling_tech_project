{{
    config(
        materialized='incremental',
        unique_key='r_regionkey',
        strategy='merge'
    )
}}

SELECT 
    r_regionkey,
    r_name,
    r_comment,
    CURRENT_TIMESTAMP() AS RAW_LOADED_AT
FROM {{ source('tpch_source', 'region') }}

{% if is_incremental() %}
    WHERE r_regionkey > (SELECT COALESCE(MAX(r_regionkey), 0) FROM {{ this }})
{% endif %}