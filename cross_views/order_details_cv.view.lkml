view: order_details_cv {
  dimension: margin {
    type: number
    sql: ${order_details.sale_price}-${products.cost} ;;
    view_label: "Order Details"
  }

  measure:total_cost {
    type: sum
    sql: ${products.cost} ;;

  }

  measure: average_cost {
    type: average
    sql: ${products.cost} ;;
    view_label: "Products"
  }

  set: product_dd {
    fields: [products.name,order_details.total_gross_margin,order_details.total_gross_revenue, order_details.gross_margin_percent]
  }

  dimension: customer_lifespan {
    type: number
    sql: date_diff(${cust_behavior.latest_order_date},${users.created_date},month) ;;
    view_label: "Users"
  }

  dimension: days_since_signup {
    type: number
    sql: date_diff(${order_details.created_date},${users.created_date},day) ;;
  }

  dimension: is_new_customer {
    type: yesno
    sql: date_diff(current_date,${users.created_date},day)<=90 ;;
    view_label: "Users"
  }

  dimension:months_since_signup {
    type: number
    sql: date_diff(${order_details.created_date},${users.created_date},month) ;;
  }

  dimension: days_to_first_order {
    type: number
    sql: date_diff(${cust_behavior.first_order_date},${users.created_date},day) ;;
    view_label: "Order Details"
  }

  measure: average_spend_per_customer {
    type: number
    sql: ${order_details.total_sale_price}/${order_details.num_total_users} ;;
    value_format_name: usd
    view_label: "Order Details"
  }

  measure: average_customer_lifespan {
      type: average
      sql: ${customer_lifespan} ;;
      value_format_name: decimal_0
      view_label: "Users"
    }

    measure: average_gross_margin {
      type: average
      filters: [order_details.iscomplete: "yes"]
      sql: ${margin} ;;
      view_label: "Order Details"
    }

  measure: average_days_to_first_order {
      type: average
      sql: ${days_to_first_order} ;;
      value_format_name: decimal_0
      view_label: "Order Details"
    }

  measure:total_gross_margin {
      type:sum
      filters: [order_details.iscomplete: "yes"]
      sql: ${margin} ;;
      value_format_name: usd
      drill_fields: [product_dd*]
      view_label: "Order Details"
    }

  measure: gross_margin_percent {
      type: number
      sql: ${total_gross_margin}/nullif(${order_details.total_gross_revenue},0) ;;
      value_format_name: percent_2
      view_label: "Order Details"
    }

}
