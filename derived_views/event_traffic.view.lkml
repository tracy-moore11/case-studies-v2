view: event_traffic {
  derived_table: {
    sql:
      select id as order_id, traffic_source from (
      select oi.id, e.traffic_source, oi.created_at, e.created_at,
        row_number() over (partition by oi.id order by date_diff(oi.created_at, e.created_at,day)) as rn
      from order_items oi left join events e on oi.user_id=e.user_id and oi.created_at>=e.created_at and e.event_type='purchase'
      )
      where rn=1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
    primary_key: yes
  }

  dimension: traffic_source {
    sql: ${TABLE}.traffic_source ;;
  }

  set: detail {
    fields: [order_id]
  }
}
