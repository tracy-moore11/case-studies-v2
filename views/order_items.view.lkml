view: order_items {

  sql_table_name: `looker-partners.thelook.order_items`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    hidden: yes
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

  dimension: iscancelled {
    type: yesno
    sql: ${status}='Cancelled ;;
  }

  dimension: iscomplete {
    type: yesno
    sql: ${status}!="Cancelled" and ${returned_raw} is null ;;
  }

  dimension: isreturned {
    type: yesno
    sql: ${returned_raw} is not null ;;
  }

  dimension: order_id {
    type: number
    hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension: product_id {
    type: number
    hidden: yes
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
    hidden: yes
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    hidden: yes
    sql: ${TABLE}.sale_price ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  ##--MEASURES--##

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
    value_format_name: percent_2
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
    sql:{% if show_to_date._parameter_value == 'Yes' %}
            ${gross_revenue_ytd}
        {% elsif show_to_date._parameter_value == 'Yes' %}
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
    sql:{% if show_to_date._parameter_value == 'Yes' %}
            ${num_total_orders_ytd}
        {% elsif show_to_date._parameter_value == 'Yes' %}
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
