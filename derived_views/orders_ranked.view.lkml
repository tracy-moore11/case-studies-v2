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

  dimension: hassubsequentorders {
    type: yesno
    sql: ${order_sequence}=1 and ${next_order_date_date} is not null ;;
  }

  dimension: isfirstpurchase {
    type: yesno
    sql: ${order_sequence}=1 ;;
  }

  dimension_group: previous_order_date {
    type: time
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
    sql: ${TABLE}.next_order_date ;;
  }

  dimension: order_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: order_start_date {
    type: time
    sql: ${TABLE}.order_start_date ;;
  }

  dimension_group: order_end_date {
    type: time
    sql: ${TABLE}.order_end_date ;;
  }

  dimension: repeat_purchase_60_days{
    type: yesno
    sql: ${daysbetweenorders}<=60 ;;
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
  }

  measure: repeat_purchase_rate_60_days{
    type: number
    sql:${total_60_day_repeat_customers}/nullif(${total_customers},0)  ;;
  }

  measure: total_60_day_repeat_customers {
    type: count_distinct
    sql: ${user_id} ;;
    filters: [repeat_purchase_60_days: "yes"]
  }

  measure: total_customers {
    type: count_distinct
    sql:${user_id}
  }

  measure: total_orders {
    type: count
  }

  measure: total_repeat_orders {
    type: count
    filters: [order_sequence:">1"]
  }

  measure: total_users {
    type: count_distinct
    sql:${user_id} ;;
  }

  set: detail {
    fields: [
      user_id,
      order_id,
      order_start_date_time,
      order_end_date_time,
      order_sequence,
      previous_order_id,
      previous_order_date_time,
      next_order_id,
      next_order_date_time
    ]
  }
}
