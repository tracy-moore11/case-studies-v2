view: customers_cv {

  ##--dimensions--##
  dimension: customer_lifespan {
    type: number
    sql: date_diff(${cust_behavior.latest_order_date},${users.created_date},month) ;;
    view_label: "Users"
  }

  dimension: days_since_signup {
    type: number
    sql: date_diff(${order_details.created_date},${users.created_date},day) ;;
  }

  dimension: days_to_first_order {
    type: number
    sql: date_diff(${cust_behavior.first_order_date},${users.created_date},day) ;;
    view_label: "Order Details"
  }

  dimension: has_order_last_30_days {
    type: yesno
    sql: date_diff(current_date,${cust_behavior.latest_order_date},day)<=30 ;;
  }

  dimension: has_order_last_90_days {
    type: yesno
    sql: date_diff(current_date, ${cust_behavior.latest_order_date},day)<=90 ;;
  }

  dimension: is_new_customer {
    type: yesno
    sql: date_diff(current_date,${users.created_date},day)<=90 ;;
    view_label: "Users"
  }

  dimension: margin {
    type: number
    sql: ${order_details.sale_price}-${products.cost} ;;
    view_label: "Order Details"
  }

  dimension:months_since_signup {
    type: number
    sql: date_diff(${order_details.created_date},${users.created_date},month) ;;
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

  ##--measures--##

  measure: average_cost {
    type: average
    sql: ${products.cost} ;;
    view_label: "Products"
  }

  measure: average_customer_lifespan {
    type: average
    sql: ${customer_lifespan} ;;
    value_format_name: decimal_0
    view_label: "Users"
  }

  measure: average_days_to_first_order {
    type: average
    sql: ${days_to_first_order} ;;
    value_format_name: decimal_0
    view_label: "Order Details"
  }

  measure: average_gross_margin {
    type: average
    filters: [order_details.iscomplete: "yes"]
    sql: ${margin} ;;
    view_label: "Order Details"
  }

  measure: average_spend_per_customer {
    type: number
    sql: ${order_details.total_sale_price}/${order_details.num_total_users} ;;
    value_format_name: usd
    view_label: "Order Details"
  }

  measure: gross_margin_percent {
    type: number
    sql: ${total_gross_margin}/nullif(${order_details.total_gross_revenue},0) ;;
    value_format_name: percent_2
    view_label: "Order Details"
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

  measure: num_customers_90_days {
    type: count_distinct
    filters: [has_order_last_90_days: "yes"]
    sql: ${order_details.user_id} ;;
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

  ##for testing
  measure: sum_days_to_first_order {
    type: sum
    sql: ${days_to_first_order} ;;
  }

  measure:total_cost {
    type: sum
    sql: ${products.cost} ;;
  }

  measure:total_gross_margin {
    type:sum
    filters: [order_details.iscomplete: "yes"]
    sql: ${margin} ;;
    value_format_name: usd
    drill_fields: [product_dd*]
    view_label: "Order Details"
  }

##--parameters--##
  parameter: show_to_date {
    type: unquoted
    allowed_value: {value: "Yes"}
    allowed_value: {value:"No"}
  }

  set: product_dd {
    fields: [products.name,order_details.total_gross_margin,order_details.total_gross_revenue, order_details.gross_margin_percent]
  }
  }
