require File.expand_path "../../../config/environment", __FILE__

Card::Auth.current_id = Card.fetch_id "Ethan McCutchen"

METRICS =
  [
    "ccc-pe-19+Action plan for living wages",
    "ccc-pe-19+References to a living wage",
    "ccc-pe-19+Supply chain transparence",
    "ccc-pe-19+Wage transparence"
  ]

OPTIONS = '
{ "yes": "ccc-pe-19.yes",
  "partial": "ccc-pe-19.partial",
  "nothing found": "ccc-pe-19.notFound"
}'

METRICS.each do |metric_name|
  vo = Card[metric_name].value_options_card
  vo.update! type: "JSON", content: OPTIONS
end

