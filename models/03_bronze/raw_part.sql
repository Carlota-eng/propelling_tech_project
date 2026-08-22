{{
    config(
        materialized='incremental',
        unique_key='p_partkey',
        incremental_strategy='merge'
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
    CURRENT_TIMESTAMP() AS RAW_LOADED_AT
FROM {{ source('tpch_source', 'part') }}

{{ incremental_filter('p_partkey') }}