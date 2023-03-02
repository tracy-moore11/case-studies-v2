include: "/pop_views/order_items_pop_np.view.lkml"
include: "/derived_views/orders_ranked.view.lkml"
explore: pop_np {
  label: "Order Details PoP"
  group_label: "Tracy M Case Studies"
  from: order_items_pop_np
  persist_with: daily_etl
  sql_always_where: ${created_raw}<=current_timestamp and ${created_raw}>'2020-01-01' ;;
  join: orders_ranked {
    type: inner
    sql_on: ${pop_np.order_id}=${orders_ranked.order_id} ;;
    relationship: many_to_one
  }
}
