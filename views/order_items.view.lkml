view: order_items {

  sql_table_name: `looker-partners.thelook.order_items`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  # dimension: customer_lifespan {
  #   type: number
  #   sql: date_diff(${cust_behavior.latest_order_date},${users.created_date},day) ;;
  # }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.delivered_at ;;
  }

  dimension: has_order_last_30_days {
    type: yesno
    sql: date_diff(current_date,${cust_behavior.latest_order_date},day)<=30 ;;
  }

  dimension: has_order_last_90_days {
    type: yesno
    sql: date_diff(current_date,${cust_behavior.latest_order_date},day)<=90 ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: iscancelled {
    type: yesno
    sql: ${status}='Cancelled ;;
  }

  dimension: iscomplete {
    type: yesno
    sql: ${status}!="Cancelled" and ${returned_raw} is null ;;
  }

  # dimension: is_new_customer {
  #   type: yesno
  #   sql: date_diff(current_date,${users.created_date},day)<=90 ;;
  # }

  dimension: isreturned {
    type: yesno
    sql: ${returned_raw} is not null ;;
  }

  # dimension: margin {
  #   type: number
  #   sql: ${sale_price}-${products.cost} ;;
  # }

  # dimension:months_since_signup {
  #   type: number
  #   sql: date_diff(${order_details.created_date},${users.created_date},month) ;;
  # }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: product_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.shipped_at ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  # dimension: days_to_first_order {
  #   type: number
  #   sql: date_diff(${cust_behavior.first_order_date},${users.created_date},day) ;;
  # }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  ##--MEASURES--##

  # measure: average_cost {
  #   type: average
  #   sql: ${products.cost} ;;
  # }

  # measure: average_customer_lifespan {
  #   type: average
  #   sql: ${customer_lifespan} ;;
  #   value_format_name: decimal_0
  # }

  # measure: average_gross_margin {
  #   type: average
  #   filters: [iscomplete: "yes"]
  #   sql: ${margin} ;;
  # }

  # measure: average_spend_per_customer {
  #   type: number
  #   sql: ${total_sale_price}/${num_total_users} ;;
  #   value_format_name: usd
  # }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
  }

  # measure: average_days_to_first_order {
  #   type: average
  #   sql: ${days_to_first_order} ;;
  #   value_format_name: decimal_0
  # }

  measure: cumulative_total_sales {
    type: running_total
    sql: ${total_sale_price} ;;
  }

  measure: first_order_date {
    type: date
    sql: min(${created_date}) ;;
  }

  # measure: gross_margin_percent {
  #   type: number
  #   sql: ${total_gross_margin}/nullif(${total_gross_revenue},0) ;;
  #   value_format_name: percent_2
  # }

  measure: item_return_rate {
    type: number
    sql: ${number_items_returned}/${count} ;;
  }

  measure: latest_order_date {
    type: date
    sql: max(${created_date}) ;;
  }

  measure: number_customers_returning_items {
    type: count_distinct
    filters: [isreturned: "yes"]
    sql: ${user_id} ;;
  }

  measure: number_items_returned {
    type: count
    filters: [isreturned: "yes"]
  }

  measure: num_repeat_orders {
    type: count_distinct
    filters: [cust_behavior.is_repeat_customer: "yes"]
    sql: ${order_id} ;;
  }

  measure: num_total_orders {
    type: count_distinct
    sql: ${order_id} ;;
  }

  measure: num_total_users {
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: percent_repeat_customers{
    type: number
    sql: ${num_repeat_orders}/${num_total_orders} ;;
    value_format_name: percent_2
  }

  measure: percent_users_with_return {
    type: number
    sql: ${number_customers_returning_items}/nullif(${num_total_users},0) ;;
  }

  # measure:total_cost {
  #   type: sum
  #   sql: ${products.cost} ;;
  # }

  # measure:total_gross_margin {
  #   type:sum
  #   filters: [iscomplete: "yes"]
  #   sql: ${margin} ;;
  #   value_format_name: usd
  #   drill_fields: [product_dd*]
  # }

  measure: total_gross_revenue {
    type: sum
    filters: [iscomplete: "yes"]
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: total_users_last_90_days {
    type: count_distinct
    sql: ${user_id} ;;
    filters: [has_order_last_90_days: "yes"]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # set: product_dd {
  #   fields: [products.name,total_gross_margin,total_gross_revenue, gross_margin_percent]
  # }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.last_name,
      users.id,
      users.first_name,
      inventory_items.id,
      inventory_items.product_name,
      products.name,
      products.id
    ]
  }
}
