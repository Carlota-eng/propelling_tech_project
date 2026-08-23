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
),

-- total de veces que se compra cada pieza por cliente
customer_product_counts AS (
    SELECT
        o.FK_CUSTOMER,
        p.AT_PART_NAME,
        COUNT(l.FK_PART)        AS PURCHASE_COUNT
    FROM {{ ref('fact_orders') }} o
    JOIN {{ ref('fact_lineitem') }} l ON o.ID_ORDER = l.FK_ORDER
    JOIN {{ ref('dim_part') }} p ON l.FK_PART = p.ID_PART
    GROUP BY o.FK_CUSTOMER, p.AT_PART_NAME
),

-- obtener las 3 primeras posiciones para el top_3
customer_top_products AS (
    SELECT
        FK_CUSTOMER,
        MAX(CASE WHEN rn = 1 THEN AT_PART_NAME END) AS AT_FAVORITE_PRODUCT_1,
        MAX(CASE WHEN rn = 2 THEN AT_PART_NAME END) AS AT_FAVORITE_PRODUCT_2,
        MAX(CASE WHEN rn = 3 THEN AT_PART_NAME END) AS AT_FAVORITE_PRODUCT_3
    FROM (
        SELECT 
            FK_CUSTOMER,
            AT_PART_NAME,
            ROW_NUMBER() OVER (PARTITION BY FK_CUSTOMER ORDER BY PURCHASE_COUNT DESC) as rn
        FROM customer_product_counts
    )
    WHERE rn <= 3
    GROUP BY FK_CUSTOMER
)

SELECT
    C.ID_CUSTOMER,
    C.AT_CUSTOMER_NAME,
    C.AT_MARKET_SEGMENT,
    C.AT_CUSTOMER_TIER,
    C.IS_VIP_CUSTOMER,
    R.AT_REGION_NAME,
    N.AT_NATION_NAME,
    F.AT_FAVORITE_PRODUCT_1,
    F.AT_FAVORITE_PRODUCT_2,
    F.AT_FAVORITE_PRODUCT_3,
    COALESCE(O.MT_TOTAL_ORDERS, 0)      AS MT_TOTAL_ORDERS,
    COALESCE(O.MT_LIFETIME_VALUE, 0)    AS MT_LIFETIME_VALUE,
    O.DT_LAST_ORDER,
    O.MT_URGENT_ORDERS_COUNT,
    C.MT_ACCOUNT_BALANCE
FROM {{ ref('dim_customer') }} AS C
LEFT JOIN customer_orders AS O ON C.ID_CUSTOMER = O.FK_CUSTOMER
LEFT JOIN customer_top_products AS F ON C.ID_CUSTOMER = F.FK_CUSTOMER
JOIN {{ ref('lkp_nation') }} AS N ON C.FK_NATION = N.ID_NATION
JOIN {{ ref('lkp_region') }} AS R ON N.FK_REGION = R.ID_REGION