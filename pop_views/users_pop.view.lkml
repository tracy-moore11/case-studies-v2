include: "/views/users.view.lkml"
view: users_pop {
  extends: [users]

  parameter: choose_comparison {
    label: "Choose Comparison (Pivot)"
    view_label: "_PoP_np"
    type: unquoted
    default_value: "Year"
    allowed_value: {value: "Year"}
    allowed_value: {value: "Month"}
  }

  dimension: pop_row {
    view_label: "_PoP_np"
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
    view_label: "_PoP"
    type: yesno
    sql:  EXTRACT(DAYOFYEAR FROM ${created_raw}) <= EXTRACT(DAYOFYEAR FROM current_date) ;;
  }
  measure: signups_dyn {
    label: "Signups"
    type: number
    sql:{% if show_to_date._parameter_value == 'Yes' and choose_comparison._parameter_value == 'Year' %}
            ${signups_ytd}
        {% elsif show_to_date._parameter_value == 'Yes' and choose_comparison._parameter_value=='Month' %}
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
  }
