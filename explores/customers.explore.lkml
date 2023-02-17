include: "/views/users.view.lkml"
include: "/derived_views/cust_behavior.view.lkml"

explore: customers {
  from: users
  join: cust_behavior {
    type: left_outer
    sql_on: ${customers.id}=${cust_behavior.user_id} ;;
    relationship: one_to_one
  }
}
