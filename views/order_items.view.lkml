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

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: iscomplete {
    type: yesno
    sql: ${status}!="Cancelled" and ${returned_raw} is null ;;
  }

  dimension: is_new_customer {
    type: yesno
    sql: date_diff(current_date,${users.created_date},day)<=90 ;;
  }

  dimension: isreturned {
    type: yesno
    sql: ${returned_raw} is not null ;;
  }

  dimension: margin {
    type: number
    sql: ${sale_price}-${products.cost} ;;
  }

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

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  ##--MEASURES--##

  measure: average_cost {
    type: average
    sql: ${products.cost} ;;
  }

  measure: average_gross_margin {
    type: average
    filters: [iscomplete: "yes"]
    sql: ${margin} ;;
  }

  measure: average_spend_per_customer {
    type: number
    sql: ${total_sale_price}/${num_total_users} ;;
    value_format_name: usd
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
  }

  measure: cumulative_total_sales {
    type: running_total
    sql: ${total_sale_price} ;;
  }

  measure: first_order_date {
    type: date
    sql: min(${created_date}) ;;
  }

  measure: gross_margin_percent {
    type: number
    sql: ${total_gross_margin}/nullif(${total_gross_revenue},0) ;;
    value_format_name: percent_2
  }

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

  measure: num_total_orders {
    type: count_distinct
    sql: ${order_id} ;;
  }

  measure: num_total_users {
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: percent_users_with_return {
    type: number
    sql: ${number_customers_returning_items}/nullif(${num_total_users},0) ;;
  }

  measure:total_cost {
    type: sum
    sql: ${products.cost} ;;
  }

  measure:total_gross_margin {
    type:sum
    filters: [iscomplete: "yes"]
    sql: ${margin} ;;
  }

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

  measure: count {
    type: count
    drill_fields: [detail*]
  }

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
