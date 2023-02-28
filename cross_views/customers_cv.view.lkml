view: customers_cv {
  dimension: has_order_last_30_days {
    type: yesno
    sql: date_diff(current_date,${cust_behavior.latest_order_date},day)<=30 ;;
  }

  dimension: has_order_last_90_days {
    type: yesno
    sql: date_diff(current_date,${cust_behavior.latest_order_date},day)<=90 ;;
  }

  measure: num_repeat_orders {
    type: count_distinct
    filters: [cust_behavior.is_repeat_customer: "yes"]
    sql: ${order_details.order_id} ;;
  }

  measure: percent_repeat_customers{
    type: number
    sql: ${num_repeat_orders}/${order_details.num_total_orders} ;;
    value_format_name: percent_2
  }

  measure: total_users_last_90_days {
    type: count_distinct
    sql: ${order_details.user_id} ;;
    filters: [customers_cv.has_order_last_90_days: "yes"]
  }
  parameter: show_to_date {
    type: unquoted
    allowed_value: {value: "Yes"}
    allowed_value: {value:"No"}
  }
  dimension: mtd_only {
    group_label: "To-Date Filters"
    label: "MTD"
    view_label: "_PoP"
    type: yesno
    sql:  EXTRACT(DAY FROM ${users.created_raw}) <= EXTRACT(DAY FROM current_date) ;;
  }

  dimension: ytd_only {
    group_label: "To-Date Filters"
    label: "YTD"
    view_label: "_PoP"
    type: yesno
    sql:  EXTRACT(DAYOFYEAR FROM ${users.created_raw}) <= EXTRACT(DAYOFYEAR FROM current_date) ;;
  }
  measure: gross_revenue_dyn {
    type: number
    sql:{% if show_to_date._parameter_value == 'Yes' %}
            ${gross_revenue_ytd}
        {% elsif show_to_date._parameter_value == 'Yes' %}
            ${gross_revenue_mtd}
        {% else %}
            ${order_details.total_gross_revenue}
        {% endif %} ;;
    value_format_name: usd
  }

  measure: gross_revenue_mtd {
    type: sum
    filters: [order_details.iscomplete: "yes", mtd_only: "yes"]
    sql: ${order_details.sale_price} ;;
    value_format_name: usd
  }


  measure: gross_revenue_ytd {
    type: sum
    filters: [order_details.iscomplete: "yes", ytd_only: "yes"]
    sql: ${order_details.sale_price} ;;
    value_format_name: usd
  }

  }
