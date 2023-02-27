view: orders_ranked {
  derived_table: {
    sql: with order_dates as (
      select user_id, order_id, min(created_at) order_start_date, max(created_at) order_end_date
      from order_items
      group by 1,2
      ),
order_rank as (
      select user_id, order_id, order_start_date, order_end_date,
        row_number() over (partition by user_id order by order_start_date) as rn
      from order_dates
      )

      select *,lag(order_id) over (partition by user_id order by rn) as last_order_id,
      lag(order_start_date) over (partition by user_id order by rn) as last_order_date,
      lag(order_id) over (partition by user_id order by rn desc) as next_order_id,
      lag(order_start_date) over (partition by user_id order by rn desc) as next_order_date
      from order_rank
      ;;
  }

  # measure: count {
  #   type: count
  #   drill_fields: [detail*]
  # }

  dimension: daysbetweenorders {
    type: number
    sql: date_diff(${order_start_date_date},${previous_order_date_date},day) ;;
  }

  dimension: has_order_last_30_days {
    type: yesno
    sql: date_diff(current_date,${order_start_date_date},day)<=30 ;;
  }

  dimension: hassubsequentorder {
    type: yesno
    sql: ${next_order_id} is not null ;;
  }

  dimension: isfirstpurchase {
    type: yesno
    sql: ${order_sequence}=1 ;;
  }

  dimension: isonetimecustomer {
    type: yesno
    sql: ${isfirstpurchase} and ${next_order_id} is null ;;
  }

  dimension_group: previous_order_date {
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
    sql: ${TABLE}.last_order_date ;;
  }

  dimension: previous_order_id {
    type: number
    sql: ${TABLE}.last_order_id ;;
  }

  dimension: next_order_id {
    type: number
    sql: ${TABLE}.next_order_id ;;
  }

  dimension_group: next_order_date {
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
    sql: ${TABLE}.next_order_date ;;
  }

  dimension: order_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: order_start_date {
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
    sql: ${TABLE}.order_start_date ;;
  }

  dimension_group: order_end_date {
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
    sql: ${TABLE}.order_end_date ;;
  }

  dimension: repeat_purchase_60_days{
    type: yesno
    sql: ${daysbetweenorders}<=60 AND ${order_sequence}=2 ;;
  }



  dimension: order_sequence {
    type: number
    sql: ${TABLE}.rn ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  measure: average_daysbetweenorders {
    type: average
    sql: ${daysbetweenorders} ;;
    value_format_name: decimal_0
  }

  measure: average_daysbetween_firstandsecond_orders {
    type: average
    sql: ${daysbetweenorders} ;;
    filters: [order_sequence: "2"]
    value_format_name: decimal_0
  }

  measure: repeat_purchase_rate {
    type: number
    sql: 1.0*(${total_repeat_orders}/nullif(${total_orders},0)) ;;
  }

  measure: repeat_purchase_rate_60_days{
    type: number
    sql:${total_60_day_repeat_customers}/nullif(${total_customers},0)  ;;
    value_format_name: percent_2
  }

  measure: total_60_day_repeat_customers {
    type: count_distinct
    sql: ${user_id} ;;
    filters: [repeat_purchase_60_days: "yes"]
  }

  measure: total_customers {
    type: count_distinct
    sql:${user_id} ;;
  }

  measure: total_orders {
    type: count
  }

  measure: total_repeat_orders {
    type: count
    filters: [order_sequence:">1"]
  }

  set: detail {
    fields: [
      user_id,
      order_id,
      order_start_date_date,
      order_end_date_date,
      order_sequence,
      previous_order_id,
      previous_order_date_date,
      next_order_id,
      next_order_date_date
    ]
  }
}
