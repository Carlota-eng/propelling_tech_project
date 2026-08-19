{{
    config(
        materialized='table',
        alias='LKP_NATION'
    )
}}

SELECT
    n_nationkey             AS ID_NATION,
    n_regionkey             AS FK_REGION,
    UPPER(TRIM(n_name))     AS AT_NATION_NAME,
    UPPER(TRIM(n_comment))  AS AT_COMMENT,
    CURRENT_TIMESTAMP()     AS AUDITTS_CREATION,
    CURRENT_TIMESTAMP()     AS AUDITTS_MODIFICATION
FROM {{ ref('raw_nation') }}