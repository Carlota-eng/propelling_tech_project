{{
    config(
        materialized='incremental',
        unique_key='ID_PART',
        incremental_strategy='merge',
        alias='DIM_PART'
    )
}}

WITH clean_part AS (
    SELECT
        p_partkey                     AS ID_PART,
        UPPER(TRIM(p_name))           AS AT_PART_NAME,
        UPPER(TRIM(p_mfgr))           AS AT_MANUFACTURER,
        UPPER(TRIM(p_brand))          AS AT_BRAND,
        UPPER(TRIM(p_type))           AS AT_PART_TYPE,
        p_size                        AS MT_SIZE,
        UPPER(TRIM(p_container))      AS AT_CONTAINER,
        p_retailprice                 AS MT_RETAIL_PRICE,
        UPPER(TRIM(p_comment))        AS AT_COMMENT,
        RAW_LOADED_AT                 AS DT_RAW_LOADED_AT
    FROM {{ ref('raw_part') }}
),

transformed_part AS (
    SELECT
        ID_PART,
        AT_PART_NAME,
        AT_MANUFACTURER,
        AT_BRAND,
        AT_PART_TYPE,
        AT_CONTAINER,
        AT_COMMENT,
        MT_SIZE,
        MT_RETAIL_PRICE,
        
        -- clasificación según precio
        CASE 
            WHEN MT_RETAIL_PRICE < 1000 THEN 'ECONOMY'
            WHEN MT_RETAIL_PRICE BETWEEN 1000 AND 1500 THEN 'STANDARD'
            ELSE 'PREMIUM'
        END AS AT_PRICE_CATEGORY,
        
        -- flag para objetos grandes
        CASE 
            WHEN MT_SIZE > 30 THEN TRUE 
            ELSE FALSE 
        END AS IS_BULKY_PART,

        -- audit
        DT_RAW_LOADED_AT AS AUDITTS_CREATION,
        CURRENT_TIMESTAMP() AS AUDITTS_MODIFICATION
    FROM clean_part
)

SELECT * FROM transformed_part

-- filtro incremental estándar por ID máximo
{{ incremental_filter('ID_PART') }}