include: "/case_study_presentation/views/users.view.lkml"
include: "/case_study_presentation/derived_views/orders_ranked.view.lkml"
include: "/case_study_presentation/derived_views/cust_behavior.view.lkml"


explore: customers {
  label: "Customers"
  group_label: "Tracy M Case Studies"
  persist_with: daily_etl
  sql_always_where: ${created_raw}>='2020-01-01' and ${created_date}<current_date ;;
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
