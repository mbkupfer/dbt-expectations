{% macro test_quantile_values_between(model) %}
{% set column_name = kwargs.get('column_name', kwargs.get('arg')) %}
{% set quantile = kwargs.get('quantile', 0) %}
{% set minimum = kwargs.get('minimum', 0) %}
{% set maximum = kwargs.get('maximum', kwargs.get('arg')) %}
{% set partition_column = kwargs.get('partition_column', kwargs.get('arg')) %}
{% set partition_filter =  kwargs.get('partition_filter', kwargs.get('arg')) %}
with column_aggregate as (
 
    select
        {{ dbt_expectations.percentile_cont(column_name, quantile) }} as column_val
    from 
        {{ model }}
    {% if partition_column and partition_filter %}
    where {{ partition_column }} {{ partition_filter }}
    {% endif %}

)
select count(*)
from (

    select distinct
        column_val
    from 
        column_aggregate
    where 
        (
            column_val < {{ minimum }}
            or 
            column_val > {{ maximum }}
        )
 
    ) validation_errors
{% endmacro %}