# The name of this view in Looker is "Users"
view: users {
  sql_table_name: `looker-partners.thelook.users`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: age_tier {
    type: tier
    tiers: [15, 26, 36, 51, 66]
    sql: ${age} ;;
    style:  integer
  }
  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
    drill_fields: [location_details*]
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: created_last_month {
    type: yesno
    sql: ${created_date}>=date_trunc(date_sub(current_date(), interval 1 month),month)
      and ${created_date}<date_trunc(current_date(),month);;
  }

  dimension: created_last_year {
    type: yesno
    sql: ${created_date}>=date_trunc(date_sub(current_date(), interval 1 year),year)
      and ${created_date}<date_trunc(current_date(),year);;
  }

  dimension: days_since_signup {
    type: number
    sql: date_diff(current_date,${created_date},day) ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: months_since_signup {
    type: number
    sql: date_diff(current_date,${created_date},month) ;;
  }

  dimension: months_since_signup_cohort {
    type: tier
    tiers: [0,1,3,7]
    sql: ${months_since_signup} ;;
    style: integer
  }

  dimension: postal_code {
    type: string
    sql: ${TABLE}.postal_code ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: street_address {
    type: string
    sql: ${TABLE}.street_address ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
    drill_fields: [user_details*]
  }


##--MEASURES--##
  measure: average_age {
    type: average
    sql: ${age} ;;
  }

  measure: average_days_since_signup {
    type: average
    sql: ${days_since_signup} ;;
  }

  measure: average_months_since_signup {
    type: average
    sql: ${months_since_signup} ;;
  }

  measure: count {
    type: count
    drill_fields: [id, last_name, first_name, order_items.count, events.count]
  }

  set: location_details {
    fields: [state,city]
  }

  set: user_details {
    fields: [gender, age_tier]
  }
}
