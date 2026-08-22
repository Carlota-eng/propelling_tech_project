{{
    config(
        materialized='incremental',
        unique_key='r_regionkey',
        incremental_strategy='merge'
    )
}}

SELECT 
    r_regionkey,
    r_name,
    r_comment,
    CURRENT_TIMESTAMP() AS RAW_LOADED_AT
FROM {{ source('tpch_source', 'region') }}

{{ incremental_filter('r_regionkey') }}