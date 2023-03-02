connection: "looker_partner_demo"

include: "/case_study_presentation/explores/**.lkml"

datagroup: daily_etl {
  max_cache_age: "24 hours"
  sql_trigger: SELECT max(id) FROM order_items ;;
}
