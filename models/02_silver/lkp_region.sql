{{
    config(
        materialized='incremental',
        unique_key='ID_REGION',
        incremental_strategy='merge',
        alias='LKP_REGION'
    )
}}

WITH clean_region AS (
    SELECT
        r_regionkey                   AS ID_REGION,
        UPPER(TRIM(r_name))           AS AT_REGION_NAME,
        UPPER(TRIM(r_comment))        AS AT_COMMENT,
        RAW_LOADED_AT                 AS DT_RAW_LOADED_AT
    FROM {{ ref('raw_region') }}
),

transformed_region AS (
    SELECT
        ID_REGION,
        AT_REGION_NAME,
        AT_COMMENT,
        
        -- audits
        DT_RAW_LOADED_AT    AS AUDITTS_CREATION,
        CURRENT_TIMESTAMP() AS AUDITTS_MODIFICATION
    FROM clean_region
)

SELECT * FROM transformed_region

-- filtro incremental estándar por ID máximo
{{ incremental_filter('ID_REGION') }}