include: "/views/users.view.lkml"
include: "/derived_views/orders_ranked.view.lkml"
include: "/derived_views/cust_behavior.view.lkml"


explore: customers {
  persist_with: daily_etl
  from: users
  join: cust_behavior {
    type: left_outer
    sql_on: ${customers.id}=${cust_behavior.user_id} ;;
    relationship: one_to_one
  }
  join: orders_ranked {
    type: left_outer
    sql_on: ${customers.id}=${orders_ranked.user_id} ;;
    relationship: one_to_many
  }
}
