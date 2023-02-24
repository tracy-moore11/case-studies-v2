include: "/views/order_items.view.lkml"
include: "/views/users.view.lkml"
include: "/views/products.view.lkml"
include: "/derived_views/cust_behavior.view.lkml"
include: "/derived_views/orders_ranked.view.lkml"
include: "/cross_views/order_details_cv.view.lkml"
include: "/cross_views/customers_cv.view.lkml"

explore: order_details {
  persist_with: daily_etl
  from: order_items
  join: users {
    type: inner
    sql_on: ${order_details.user_id}=${users.id} ;;
    relationship: many_to_one
  }
  join: products {
    type: inner
    sql_on: ${order_details.product_id}=${products.id} ;;
    relationship: many_to_one
  }
  join: cust_behavior {
    type: inner
    sql_on: ${order_details.user_id}=${cust_behavior.user_id} ;;
    relationship:many_to_one
  }
  join: orders_ranked {
    type: inner
    sql_on: ${order_details.order_id}=${orders_ranked.order_id} ;;
    relationship: many_to_one
  }
  join: order_details_cv {
    relationship: one_to_one
    sql:  ;;
  }
  join: customers_cv {
    relationship: one_to_one
    sql: ;;
  }
}
