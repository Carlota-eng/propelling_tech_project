{% macro incremental_filter(id_column) %}
    {% if is_incremental() %}
        WHERE {{ id_column }} > (SELECT COALESCE(MAX({{ id_column }}), 0) FROM {{ this }})
    {% endif %}
{% endmacro %}