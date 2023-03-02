# for brand comparison case study
# compares brand to top competitor brands in selected category
include: "/case_study_presentation/views/products.view.lkml"
view: top_competitors {
  derived_table: {
    sql:
    select *, rank() over (partition by iscompetitor order by revenue desc) as rank
    from (
      select brand,
        case when brand <> {% parameter select_brand %} then true else false end as iscompetitor,
        count(distinct order_id) as num_orders, round(sum(sale_price),2) as revenue
      from order_items oi
        join products p on oi.product_id=p.id
      where category = {% parameter select_category %}
        and status<>'Cancelled' and returned_at is null
        and brand is not null
      group by 1,2
    )
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: brand {
    type: string
    primary_key: yes
    sql: ${TABLE}.brand ;;
  }

  dimension: iscompetitor {
    type: yesno
    sql: ${TABLE}.iscompetitor=true ;;
  }

  dimension: num_orders {
    type: number
    sql: ${TABLE}.num_orders ;;
  }

  dimension: rank {
    type: number
    sql: ${TABLE}.rank ;;
  }

  dimension: revenue {
    type: number
    sql: ${TABLE}.revenue ;;
  }

  measure: total_revenue {
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd
  }

  measure: total_orders {
    type: sum
    sql: ${num_orders} ;;
  }

  parameter: select_category {
    type: string
  }

  parameter: select_brand {
    type: string
  }

  set: detail {
    fields: [brand, num_orders, revenue]
  }
}
