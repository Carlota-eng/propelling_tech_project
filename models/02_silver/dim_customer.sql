{{
    config(
        materialized='incremental',
        unique_key='ID_CUSTOMER',
        incremental_strategy='merge',
        alias='DIM_CUSTOMER'
    )
}}

WITH clean_customer AS (
    SELECT
        c_custkey                    AS ID_CUSTOMER,
        c_nationkey                  AS FK_NATION,
        UPPER(TRIM(c_name))          AS AT_CUSTOMER_NAME,
        UPPER(TRIM(c_address))       AS AT_ADDRESS,
        UPPER(TRIM(c_phone))         AS AT_PHONE,
        UPPER(TRIM(c_mktsegment))    AS AT_MARKET_SEGMENT,
        UPPER(TRIM(c_comment))       AS AT_COMMENT,
        c_acctbal                    AS MT_ACCOUNT_BALANCE,
        RAW_LOADED_AT                AS DT_RAW_LOADED_AT
    FROM {{ ref('raw_customer') }}
),

transformed_customer AS (
    SELECT
        ID_CUSTOMER,
        FK_NATION,
        AT_CUSTOMER_NAME,
        AT_ADDRESS,
        AT_PHONE,
        AT_MARKET_SEGMENT,
        AT_COMMENT,
        MT_ACCOUNT_BALANCE,
        
        -- flag para clientes vip
        CASE 
            WHEN MT_ACCOUNT_BALANCE > 5000 THEN TRUE 
            ELSE FALSE 
        END AS IS_VIP_CUSTOMER,
        
        -- clasificación clientes según balance
        CASE 
            WHEN MT_ACCOUNT_BALANCE < 0 THEN 'HIGH_RISK_DEBT'
            WHEN MT_ACCOUNT_BALANCE BETWEEN 0 AND 5000 THEN 'STANDARD'
            ELSE 'PREMIUM'
        END AS AT_CUSTOMER_TIER,

        -- Auditoría interna
        DT_RAW_LOADED_AT AS AUDITTS_CREATION,
        CURRENT_TIMESTAMP() AS AUDITTS_MODIFICATION
    FROM clean_customer
)

SELECT * FROM transformed_customer

-- filtro incremental estándar por ID máximo
{{ incremental_filter('ID_CUSTOMER') }}