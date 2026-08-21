{{
    config(
        materialized='incremental',
        unique_key='ID_NATION',
        incremental_strategy='merge',
        alias='LKP_NATION',
        update_columns=[
            'FK_REGION',
            'AT_NATION_NAME',
            'AT_COMMENT',
            'AUDITTS_MODIFICATION'
        ]
    )
}}

WITH clean_nation AS (
    SELECT
        n_nationkey                  AS ID_NATION,
        n_regionkey                  AS FK_REGION,
        UPPER(TRIM(n_name))          AS AT_NATION_NAME,
        UPPER(TRIM(n_comment))       AS AT_COMMENT,
        RAW_LOADED_AT                AS DT_RAW_LOADED_AT
    FROM {{ ref('raw_nation') }}
),

transformed_nation AS (
    SELECT
        ID_NATION,
        FK_REGION,
        AT_NATION_NAME,
        AT_COMMENT,
        
        -- audits
        DT_RAW_LOADED_AT AS AUDITTS_CREATION,
        CURRENT_TIMESTAMP() AS AUDITTS_MODIFICATION
    FROM clean_nation
)

SELECT * FROM transformed_nation

{% if is_incremental() %}
    WHERE ID_NATION > (SELECT COALESCE(MAX(ID_NATION), 0) FROM {{ this }})
{% endif %}