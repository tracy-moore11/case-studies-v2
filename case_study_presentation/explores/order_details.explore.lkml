include: "/case_study_presentation/views/order_items.view.lkml"
include: "/case_study_presentation/views/users.view.lkml"
include: "/case_study_presentation/views/products.view.lkml"
include: "/case_study_presentation/derived_views/cust_behavior.view.lkml"
include: "/case_study_presentation/derived_views/orders_ranked.view.lkml"
include: "/case_study_presentation/cross_views/customers_cv.view.lkml"

explore: order_details {
  label: "Case Study Order Details"
  group_label: "Tracy M Case Studies"
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
  join: customers_cv {
    relationship: one_to_one
    sql: ;;
  }
}
