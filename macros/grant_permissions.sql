{% macro grant_permissions() %}

    {% set query %}
        -- Otorga permisos en la base de datos de trabajo
        GRANT ALL PRIVILEGES ON DATABASE {{ target.database }} TO ROLE DBT_ROLE;
        
        -- Otorga permisos en el esquema donde se crean las tablas
        GRANT ALL PRIVILEGES ON SCHEMA {{ target.database }}.{{ target.schema }} TO ROLE DBT_ROLE;
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA {{ target.database }}.{{ target.schema }} TO ROLE DBT_ROLE;
        GRANT ALL PRIVILEGES ON ALL VIEWS IN SCHEMA {{ target.database }}.{{ target.schema }} TO ROLE DBT_ROLE;
    {% endset %}

    {% do run_query(query) %}
    {% do log("Permisos otorgados automáticamente en " ~ target.database ~ "." ~ target.schema, info=True) %}

{% endmacro %}