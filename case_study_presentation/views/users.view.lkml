# The name of this view in Looker is "Users"
view: users {
  sql_table_name: `looker-partners.thelook.users`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    hidden: yes
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    hidden: yes
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

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
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

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
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
  }

  parameter: show_to_date {
    type: unquoted
    allowed_value: {value: "Yes"}
    allowed_value: {value:"No"}
  }
  dimension: mtd_only {
    group_label: "To-Date Filters"
    label: "MTD"
    view_label: "_PoP"
    type: yesno
    sql:  EXTRACT(DAY FROM ${created_raw}) <= EXTRACT(DAY FROM current_date) ;;
  }

  dimension: ytd_only {
    group_label: "To-Date Filters"
    label: "YTD"
    view_label: "_users_PoP"
    type: yesno
    sql:  EXTRACT(DAYOFYEAR FROM ${created_raw}) <= EXTRACT(DAYOFYEAR FROM current_date) ;;
  }
  measure: signups_dyn {
    label: "Signups"
    type: number
    sql:{% if show_to_date._parameter_value == 'Yes' %}
            ${signups_ytd}
        {% elsif show_to_date._parameter_value == 'Yes' %}
            ${signups_mtd}
        {% else %}
            ${count}
        {% endif %} ;;
  }

  measure: signups_mtd {
    type: count
    filters: [mtd_only: "yes"]
  }


  measure: signups_ytd {
    type: count
    filters: [ytd_only: "yes"]
  }

  set: location_details {
    fields: [state,city]
  }

  set: user_details {
    fields: [gender, age_tier]
  }

  parameter: choose_comparison {
    label: "Choose Comparison (Pivot)"
    view_label: "users_PoP"
    type: unquoted
    default_value: "Year"
    allowed_value: {value: "Year"}
    allowed_value: {value: "Month"}
  }

  dimension: pop_row {
    view_label: "users_PoP"
    label_from_parameter: choose_comparison
    type: string
    order_by_field: sort_hack2
    sql:
    {% if choose_comparison._parameter_value == 'Year' %} ${created_year}
    {% elsif choose_comparison._parameter_value == 'Month' %} ${created_month}
    {% else %}NULL{% endif %};;
  }

  dimension: sort_hack2 {
    type: string
    sql:
    {% if choose_comparison._parameter_value == 'Year' %} ${created_year}
    {% elsif choose_comparison._parameter_value == 'Month' %} ${created_month}
    {% else %}NULL{% endif %};;
  }
  # parameter: show_to_date {
  #   type: unquoted
  #   allowed_value: {value: "Yes"}
  #   allowed_value: {value:"No"}
  # }
  dimension: mtd_only_pop {
    group_label: "To-Date Filters"
    label: "MTD"
    view_label: "_users_PoP"
    type: yesno
    sql:  EXTRACT(DAY FROM ${created_raw}) <= EXTRACT(DAY FROM current_date) ;;
  }

  dimension: ytd_only_pop {
    group_label: "To-Date Filters"
    label: "YTD"
    view_label: "_users_PoP"
    type: yesno
    sql:  EXTRACT(DAYOFYEAR FROM ${created_raw}) <= EXTRACT(DAYOFYEAR FROM current_date) ;;
  }
  measure: signups_dyn_pop {
    label: "Signups"
    view_label: "_users_PoP"
    type: number
    sql:{% if show_to_date._parameter_value == 'Yes' and choose_comparison._parameter_value == 'Year' %}
            ${signups_ytd_pop}
        {% elsif show_to_date._parameter_value == 'Yes' and choose_comparison._parameter_value=='Month' %}
            ${signups_mtd_pop}
        {% else %}
            ${count}
        {% endif %} ;;
  }

  measure: signups_mtd_pop {
    type: count
    filters: [mtd_only: "yes"]
  }


  measure: signups_ytd_pop {
    type: count
    filters: [ytd_only: "yes"]
  }
}
