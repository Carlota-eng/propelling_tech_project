{{
    config(
        materialized='view',
        alias='CUST_CUSTOMER_360'
    )
}}

WITH customer_orders AS (
    SELECT
        FK_CUSTOMER,
        COUNT(ID_ORDER)         AS MT_TOTAL_ORDERS,
        SUM(MT_TOTAL_PRICE)     AS MT_LIFETIME_VALUE,
        MAX(DT_ORDER)           AS DT_LAST_ORDER,
        SUM(CASE 
                WHEN IS_URGENT_ORDER THEN 1
                ELSE 0
                END)            AS MT_URGENT_ORDERS_COUNT
    FROM {{ ref('fact_orders') }}
    GROUP BY 1
)

SELECT
    C.ID_CUSTOMER,
    C.AT_CUSTOMER_NAME,
    C.AT_MARKET_SEGMENT,
    C.AT_CUSTOMER_TIER,
    C.IS_VIP_CUSTOMER,
    N.AT_NATION_NAME,
    R.AT_REGION_NAME,
    COALESCE(O.MT_TOTAL_ORDERS, 0)      AS MT_TOTAL_ORDERS,
    COALESCE(O.MT_LIFETIME_VALUE, 0)    AS MT_LIFETIME_VALUE,
    O.DT_LAST_ORDER,
    O.MT_URGENT_ORDERS_COUNT,
    C.MT_ACCOUNT_BALANCE
FROM {{ ref('dim_customer') }} AS C
LEFT JOIN customer_orders AS O ON C.ID_CUSTOMER = O.FK_CUSTOMER
JOIN {{ ref('lkp_nation') }} AS N ON C.FK_NATION = N.ID_NATION
JOIN {{ ref('lkp_region') }} AS R ON N.FK_REGION = R.ID_REGION