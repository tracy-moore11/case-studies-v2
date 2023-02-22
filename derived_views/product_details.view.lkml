view: product_details {
  derived_table: {
    sql: with order_dates as (
      select user_id, min(created_at) as first_order, max(created_at) as last_order
      from order_items
      group by 1
      )

      select oi.user_id, case when first_order=last_order then false else true end as isrepeat, p.name, p.brand, p.category, cast(oi.created_at as date) as order_date,
      row_number() over (partition by oi.user_id, brand order by oi.created_at) as brand_purchase_rank,
      row_number() over (partition by oi.user_id, category order by oi.created_at) as category_purchase_rank
      from order_items oi
      join products p on oi.product_id=p.id
      join order_dates od on oi.user_id=od.user_id
      ;;
  }

  measure: count {
    type: count
    label: "Total Purchases"
    drill_fields: [brand_drill*]
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
    can_filter:no
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
    drill_fields: [category_drill*]
  }

  dimension: hasrepeat {
    type: yesno
    sql: ${TABLE}.isrepeat=true;;
  }

  dimension: order_date {
    type: date
    datatype: date
    sql: ${TABLE}.order_date ;;
  }

  dimension: brand_purchase_rank {
    type: number
    sql: ${TABLE}.brand_purchase_rank ;;
  }

  dimension: category_purchase_rank {
    type: number
    sql: ${TABLE}.category_purchase_rank ;;
  }

  measure: percent_ot_brand_purchase {
    type: number
    label: "Brand One Time Purchase Rate"
    sql: ${total_ot_brand}/${count} ;;
    value_format_name: percent_2
  }

  measure: percent_ot_category_purchase {
    type: number
    label: "Category One Time Purchase Rate"
    sql: ${total_ot_category}/${count} ;;
    value_format_name: percent_2
  }

  measure: percent_rpt_brand_purchase {
    type: number
    label: "Brand Repeat Purchase Rate"
    sql: ${total_rpt_brand}/${count} ;;
    value_format_name: percent_2
  }

  measure: percent_rpt_category_purchase {
    type: number
    label: "Category Repeat Purchase Rate"
    sql: ${total_rpt_category}/${count} ;;
    value_format_name: percent_2
  }

  measure: total_ot_brand {
    type: count
    label: "Brand One Time Purchases"
    filters: [brand_purchase_rank: "1",hasrepeat: "no"]
  }

  measure: total_ot_category {
    type: count
    label: " Category One Time Purchases"
    filters: [category_purchase_rank: "1",hasrepeat: "no"]
  }

  measure: total_rpt_brand {
    type: count
    label: "Brand Repeat Purchases"
    filters: [brand_purchase_rank: ">1"]
  }

  measure: total_rpt_category {
    type: count
    label: "Category Repeat Purchases"
    filters: [category_purchase_rank: ">1"]
  }

  set: category_drill {
    fields: [name]
  }

  set: brand_drill {
    fields: [brand,category,name, count]
  }

  set: detail {
    fields: [
      user_id,
      name,
      brand,
      category,
      order_date,
      brand_purchase_rank,
      category_purchase_rank
    ]
  }
}
