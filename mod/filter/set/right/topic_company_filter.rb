# include_set Abstract::CollapsedFilterForm
#
# def filter_keys
#   %w(wikirate_company)
# end
#
# def default_sort_option
#   "most_metrics"
# end
#
# format :html do
#   def content_view
#     :company_tab
#   end
#
#   def sort_options
#     {
#       "Most Metrics" => "most_metrics",
#       "Most Notes" => "most_notes",
#       "Most Sources " => "most_sources",
#       "Has Overview" => "has_overview"
#     }
#   end
# end
#
#
# def default_button_formgroup_args args
#   args[:buttons] = [
#       button_formgroup_reset_button,
#       button_tag("Filter", situation: "primary", disable_with: "Filtering")
#   ].join
# end
#
# def button_formgroup_reset_button
#   link_to_card card.name.left, "Reset",
#                path: { view: content_view },
#                remote: true, class: "slotter btn btn-default margin-8"
# end
