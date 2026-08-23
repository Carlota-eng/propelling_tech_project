{{
    config(
        materialized='view',
        alias='CUST_SUPPLIER_LOGISTICS'
    )
}}

WITH supplier_metrics AS (
    SELECT
        S.ID_SUPPLIER,
        S.AT_SUPPLIER_NAME,
        S.AT_SUPPLIER_TIER,
        S.IS_HIGH_BALANCE_SUPPLIER,
        N.AT_NATION_NAME,
        R.AT_REGION_NAME,
        COUNT(L.FK_ORDER)                                       AS MT_TOTAL_ITEMS_SUPPLIED,
        SUM(CASE WHEN L.IS_DELAYED_DELIVERY THEN 1 ELSE 0 END)  AS MT_DELAYED_ITEMS_COUNT,
        ROUND(AVG(L.CA_NET_PRICE), 2)                           AS MT_AVG_SUPPLY_AMOUNT,
        SUM(CASE WHEN P.IS_BULKY_PART THEN 1 ELSE 0 END)        AS MT_BULKY_ITEMS_COUNT
    FROM {{ ref('dim_supplier') }} AS S
    JOIN {{ ref('lkp_nation') }} AS N ON S.FK_NATION = N.ID_NATION
    JOIN {{ ref('lkp_region') }} AS R ON N.FK_REGION = R.ID_REGION
    LEFT JOIN {{ ref('fact_lineitem') }} AS L ON S.ID_SUPPLIER = L.FK_SUPPLIER
    LEFT JOIN {{ ref('dim_part') }} AS P ON L.FK_PART = P.ID_PART
    GROUP BY 1, 2, 3, 4, 5, 6
),

-- calcular los productos más vendidos por cada proveedor
supplier_part_counts AS (
    SELECT
        L.FK_SUPPLIER,
        P.AT_PART_NAME,
        COUNT(L.FK_ORDER) as supply_count
    FROM {{ ref('fact_lineitem') }} AS L
    JOIN {{ ref('dim_part') }} AS P ON L.FK_PART = P.ID_PART
    WHERE L.FK_SUPPLIER IS NOT NULL
    GROUP BY 1, 2
),

-- obtener el máximo por proveedor y quedrnos con el top 3
supplier_top_parts AS (
    SELECT
        FK_SUPPLIER,
        MAX(CASE WHEN rn = 1 THEN AT_PART_NAME END) AS AT_TOP_SUPPLIED_PRODUCT_1,
        MAX(CASE WHEN rn = 2 THEN AT_PART_NAME END) AS AT_TOP_SUPPLIED_PRODUCT_2,
        MAX(CASE WHEN rn = 3 THEN AT_PART_NAME END) AS AT_TOP_SUPPLIED_PRODUCT_3
    FROM (
        SELECT 
            FK_SUPPLIER,
            AT_PART_NAME,
            ROW_NUMBER() OVER (PARTITION BY FK_SUPPLIER ORDER BY supply_count DESC) as rn
        FROM supplier_part_counts
    )
    WHERE rn <= 3
    GROUP BY FK_SUPPLIER
)

SELECT
    M.ID_SUPPLIER,
    M.AT_SUPPLIER_NAME,
    M.AT_SUPPLIER_TIER,
    M.IS_HIGH_BALANCE_SUPPLIER,
    M.AT_REGION_NAME,
    M.AT_NATION_NAME,
    P.AT_TOP_SUPPLIED_PRODUCT_1,
    P.AT_TOP_SUPPLIED_PRODUCT_2,
    P.AT_TOP_SUPPLIED_PRODUCT_3,
    M.MT_TOTAL_ITEMS_SUPPLIED,
    M.MT_DELAYED_ITEMS_COUNT,
    M.MT_AVG_SUPPLY_AMOUNT,
    M.MT_BULKY_ITEMS_COUNT
FROM supplier_metrics AS M
LEFT JOIN supplier_top_parts AS P ON M.ID_SUPPLIER = P.FK_SUPPLIER