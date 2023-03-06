# view that specifically sees if a brand or category was purchased multiple times by the same customer
# used for repeat product information

view: repeat_product_detail {
  derived_table: {
    sql: select user_id, oi.id as order_item_id, order_id, product_id, created_at,category,brand, p.name, row_number() over (partition by user_id, brand order by created_at) as brand_rn,
        row_number() over (partition by user_id, category order by created_at) as category_rn
      from order_items oi
        join products p on oi.product_id=p.id
       ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
    # drill_fields: [brand_drill*]
  }

  dimension: brand_rn {
    type: number
    sql: ${TABLE}.brand_rn ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
    # drill_fields: [category_drill*]
  }

  dimension: category_rn {
    type: number
    sql: ${TABLE}.category_rn ;;
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

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }


  dimension: order_item_id {
    type: number
    sql: ${TABLE}.order_item_id ;;
    primary_key: yes
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

##--measures--##

  measure: brand_repeat_rate {
    type: number
    sql: ${total_brand_repeat_orders}/${count} ;;
    value_format_name: percent_2
  }

  measure: category_repeat_rate {
    type: number
    sql: ${total_category_repeat_orders}/${count} ;;
    value_format_name: percent_2
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_brand_repeat_orders {
    type: count
    filters: [brand_rn: ">1"]
    drill_fields: [detail*]

  }

  measure: total_category_repeat_orders{
    type: count
    filters: [category_rn: ">1"]
    drill_fields: [detail*]
  }

##--drill fields--##
  set: brand_drill {
    fields: [category,name]
  }

  set:  category_drill{
    fields: [brand,name]
  }

  set: detail {
    fields: [category, brand, name]
  }
}
