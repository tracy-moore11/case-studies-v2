include: "/views/order_items.view.lkml"
view: order_items_pop_np {
  extends: [order_items]

  parameter: choose_comparison {
    label: "Choose Comparison (Pivot)"
    view_label: "_PoP_np"
    type: unquoted
    default_value: "Year"
    allowed_value: {value: "Year"}
    allowed_value: {value: "Month"}
  }

  dimension: pop_row {
    view_label: "_PoP_np"
    label_from_parameter: choose_comparison
    type: string
    order_by_field: sort_hack2
    sql:
    {% if choose_comparison._parameter_value == 'Year' %} ${created_year}
    {% elsif choose_comparison._parameter_value == 'Month' %} ${created_month}
    {% else %}NULL{% endif %};;
  }

  dimension: sort_hack2 {
    type: string
    sql:
    {% if choose_comparison._parameter_value == 'Year' %} ${created_year}
    {% elsif choose_comparison._parameter_value == 'Month' %} ${created_month}
    {% else %}NULL{% endif %};;
  }
  # parameter: show_to_date {
  #   type: unquoted
  #   allowed_value: {value: "Yes"}
  #   allowed_value: {value:"No"}
  # }
  dimension: mtd_only {
    group_label: "To-Date Filters"
    label: "MTD"
    view_label: "_PoP"
    type: yesno
    sql:  EXTRACT(DAY FROM ${created_raw}) <= EXTRACT(DAY FROM current_date) ;;
  }

  dimension: ytd_only {
    group_label: "To-Date Filters"
    label: "YTD"
    view_label: "_PoP"
    type: yesno
    sql:  EXTRACT(DAYOFYEAR FROM ${created_raw}) <= EXTRACT(DAYOFYEAR FROM current_date) ;;
  }
  measure: gross_revenue_dyn {
    type: number
    sql:{% if show_to_date._parameter_value == 'Yes' and choose_comparison._parameter_value == 'Year' %}
            ${gross_revenue_ytd}
        {% elsif show_to_date._parameter_value == 'Yes' and choose_comparison._parameter_value=='Month' %}
            ${gross_revenue_mtd}
        {% else %}
            ${total_gross_revenue}
        {% endif %} ;;
    value_format_name: usd
  }

  measure: gross_revenue_mtd {
    type: sum
    filters: [iscomplete: "yes", mtd_only: "yes"]
    sql: ${sale_price} ;;
    value_format_name: usd
  }


  measure: gross_revenue_ytd {
    type: sum
    filters: [iscomplete: "yes", ytd_only: "yes"]
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: num_total_orders_dyn {
    type: number
    sql:{% if show_to_date._parameter_value == 'Yes' and choose_comparison._parameter_value == 'Year' %}
            ${num_total_orders_ytd}
        {% elsif show_to_date._parameter_value == 'Yes' and choose_comparison._parameter_value=='Month' %}
            ${num_total_orders_mtd}
        {% else %}
            ${num_total_orders}
        {% endif %} ;;
  }

  measure: num_total_orders_mtd {
    type: count_distinct
    filters: [mtd_only: "yes"]
    sql: ${order_id} ;;
  }

  measure: num_total_orders_ytd {
    type: count_distinct
    filters: [ytd_only: "yes"]
    sql: ${order_id} ;;
  }




}
