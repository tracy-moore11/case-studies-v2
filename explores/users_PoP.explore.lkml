include: "/pop_views/users_pop.view.lkml"
include: "/derived_views/cust_behavior.view.lkml"
explore: users_pop {
  join: cust_behavior {
    type: left_outer
    sql_on: ${users_pop.id}=${cust_behavior.user_id} ;;
    relationship: one_to_one
  }
}
