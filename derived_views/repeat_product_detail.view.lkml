view: repeat_product_detail {
  derived_table: {
    sql: select user_id, order_id,category,brand, name, row_number() over (partition by user_id, brand order by created_at) as brand_rn,
        row_number() over (partition by user_id, category order by created_at) as category_rn
      from order_items oi
        join products p on oi.product_id=p.id
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
    primary_key: yes
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
    drill_fields: [category_drill*]
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
    drill_fields: [brand_drill*]
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: brand_rn {
    type: number
    sql: ${TABLE}.brand_rn ;;
  }

  dimension: category_rn {
    type: number
    sql: ${TABLE}.category_rn ;;
  }

  measure: total_brand_repeat_orders {
    type: count
    filters: [brand_rn: ">1"]

  }

  measure: total_category_repeat_orders{
    type: count
    filters: [category_rn: ">1"]
  }

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

  set: brand_drill {
    fields: [category,name]
  }

  set:  category_drill{
    fields: [brand,name]
  }

  set: detail {
    fields: [user_id, category, brand, name, brand_rn, category_rn]
  }
}
