view: products {
  sql_table_name: `looker-partners.thelook.products`
    ;;
  drill_fields: [id]

##--DIMENSIONS--##
  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
    drill_fields: [brand_details*]
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
    drill_fields: [category_details*]
  }

  dimension: cost {
    type: number
    hidden: yes
    sql: ${TABLE}.cost ;;
  }

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

##--MEASURES--##

  measure: average_cost {
    type: average
    sql: ${cost} ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_cost {
    type: sum
    sql: ${cost} ;;
  }

##--PARAMETERS--##
  parameter: selected_brand {
    type: string
    suggest_dimension: brand
    default_value: "Calvin Klein"
  }


  parameter: select_category {
    type: string
    suggest_dimension: category
    default_value: "Jeans"
  }

  ##--DRILL FIELDS--##
  set: brand_details {
    fields: [category, name]
  }

  set: category_details {
    fields: [brand, name]
  }
  set: detail {
    fields: [
      id,
      name,
      distribution_centers.name,
      distribution_centers.id,
      order_items.count,
      inventory_items.count
    ]
  }
}
