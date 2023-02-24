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
  }
