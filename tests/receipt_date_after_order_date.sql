-- asegurar que la fecha de recepción del pedido nunca sea
-- anterior a la fecha de emisión del mismo.

{{ config(severity = 'warn') }}

SELECT 
    li.fk_order AS id_order,
    li.dt_receipt,
    o.dt_order,
    'Receipt date is earlier than order date' AS error_message
FROM {{ ref('fact_lineitem') }} li
JOIN {{ ref('fact_orders') }} o ON li.fk_order = o.id_order
WHERE li.dt_receipt < o.dt_order