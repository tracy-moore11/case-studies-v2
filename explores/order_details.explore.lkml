include: "/views/order_items.view.lkml"
include: "/views/users.view.lkml"
include: "/views/products.view.lkml"

explore: order_details {
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
}
