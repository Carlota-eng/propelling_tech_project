{{
    config(
        materialized='incremental',
        unique_key='ID_CUSTOMER',
        strategy='merge',
        alias='DIM_CUSTOMER',
        update_columns=[
            'FK_NATION', 
            'AT_CUSTOMER_NAME', 
            'AT_ADDRESS', 
            'AT_PHONE', 
            'AT_MARKET_SEGMENT', 
            'AT_COMMENT', 
            'MT_ACCOUNT_BALANCE', 
            'IS_VIP_CUSTOMER', 
            'AT_CUSTOMER_TIER', 
            'CD_MD5', 
            'AUDITTS_MODIFICATION'
        ]
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

        --generar código md5 hasheado
        md5(
            coalesce(cast(FK_NATION as string), '') || '|' ||
            coalesce(cast(AT_CUSTOMER_NAME as string), '') || '|' ||
            coalesce(cast(AT_ADDRESS as string), '') || '|' ||
            coalesce(cast(AT_PHONE as string), '') || '|' ||
            coalesce(cast(AT_MARKET_SEGMENT as string), '') || '|' ||
            coalesce(cast(AT_COMMENT as string), '') || '|' ||
            coalesce(cast(MT_ACCOUNT_BALANCE as string), '')
        ) AS CD_MD5,

        -- Auditoría interna
        DT_RAW_LOADED_AT AS AUDITTS_CREATION,
        CURRENT_TIMESTAMP() AS AUDITTS_MODIFICATION
    FROM clean_customer
)

SELECT * FROM transformed_customer

-- filtro para nuevos registros y/o modificaciones de registros existentes
{% if is_incremental() %}
    WHERE ID_CUSTOMER > (SELECT COALESCE(MAX(ID_CUSTOMER), 0) FROM {{ this }})
       OR CD_MD5 NOT IN (SELECT COALESCE(CD_MD5, '') FROM {{ this }})
{% endif %}