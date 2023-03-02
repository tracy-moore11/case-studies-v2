# for brand comparison case study
# compares selected brand's top categories other to the selected category
view: category_compare {
  derived_table: {
    sql: select *, rank() over (partition by iscategory order by revenue desc) as rank
      from (select category,
              case when category = {% parameter select_category %} then true else false end as iscategory,
              count(distinct order_id) as num_orders, round(sum(sale_price),2) as revenue
            from order_items oi
              join products p on oi.product_id=p.id
            where brand = {% parameter select_brand %}
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

  dimension: category {
    primary_key: yes
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: iscategory {
    type: yesno
    sql: ${TABLE}.iscategory ;;
  }

  dimension: num_orders {
    type: number
    sql: ${TABLE}.num_orders ;;
  }

  dimension: revenue {
    type: number
    sql: ${TABLE}.revenue ;;
  }

  dimension: rank {
    type: number
    sql: ${TABLE}.rank ;;
  }

  parameter: select_category {
    type: string
    default_value: "Outerwear & Coats"
  }

  parameter: select_brand {
    type: string
    default_value: "Calvin Klein"
  }

  set: detail {
    fields: [category, iscategory, num_orders, revenue, rank]
  }
}
