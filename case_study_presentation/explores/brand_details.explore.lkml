include: "/case_study_presentation/derived_views/repeat_product_detail.view.lkml"
include: "/case_study_presentation/views/products.view.lkml"

explore: brand_details {
  from: repeat_product_detail
  join: products {
    type: inner
    sql_on: ${brand_details.product_id}=${products.id} ;;
    relationship: many_to_one
  }
}
