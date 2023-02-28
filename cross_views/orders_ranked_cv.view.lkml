view: orders_ranked_cv {
  measure: percent_with_sales {
    type: number
    sql: ${orders_ranked.total_customers}/${customers.count} ;;
    value_format_name: percent_2
    view_label: "Order Details"
  }
}
