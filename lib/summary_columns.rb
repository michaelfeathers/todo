SUMMARY_COLUMNS = [
  ["Life",  ->(tasks) { tasks.L.count } ],
  ["Work",  ->(tasks) { tasks.R.count + tasks.D.count } ],
  ["DRD",   ->(tasks) { tasks.D.count } ],
  ["W %",   ->(tasks) { tasks.R.percent_of(tasks) + tasks.D.percent_of(tasks)} ],
  ["Total", ->(tasks) { tasks.count } ]
].freeze
