view: cust_behavior {
  derived_table: {
    explore_source: order_details {
      column: user_id {}
      column: num_total_orders {}
      column: total_gross_revenue {}
      column: total_sale_price {}
      column: first_order_date {}
      column: latest_order_date {}
    }
  }
  dimension: user_id {
    primary_key: yes
    description: ""
    type: number
  }
  dimension: num_total_orders {
    description: ""
    type: number
  }

  dimension: total_sale_price {
    type: number
    value_format_name: usd
  }
  dimension: total_gross_revenue {
    value_format_name: usd
    type: number
  }
  dimension: first_order_date {
    description: ""
    type: number
  }

  dimension: days_since_last_order {
    type: number
    sql: date_diff(current_date,${latest_order_date},day) ;;
  }

  dimension: is_active {
    type: yesno
    sql: ${days_since_last_order}<=90 ;;
  }

  dimension: is_repeat_customer {
    type: yesno
    sql: ${num_total_orders}>1 ;;
  }
  dimension: latest_order_date {
    description: ""
    type: number
  }

  dimension: customer_lifetime_orders {
    type: tier
    tiers: [1, 2, 3, 6, 10]
    sql: ${num_total_orders} ;;
    style:  integer
  }
  dimension: customer_lifetime_revenue {
    type: tier
    tiers: [0, 5, 20, 50, 100, 500, 1000]
    sql: ${total_gross_revenue} ;;
    style:  integer
    value_format_name: usd
  }

  measure: average_lifetime_orders {
    type: average
    sql: ${num_total_orders} ;;
  }

  measure: average_lifetime_revenue {
    type: average
    sql: ${total_gross_revenue} ;;
    value_format_name: usd
  }

  measure: average_spend {
    type: average
    sql: ${total_sale_price} ;;
    value_format_name: usd
  }

  measure: total_customers {
    type: count
  }

  measure: total_lifetime_orders {
    type: sum
    sql: ${num_total_orders} ;;
  }

  measure: total_lifetime_sales {
    type: sum
    sql: ${total_sale_price} ;;
  }

  measure: total_lifetime_revenue {
    type: sum
    sql: ${total_gross_revenue} ;;
  }
}
