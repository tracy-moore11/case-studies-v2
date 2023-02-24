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
  }
