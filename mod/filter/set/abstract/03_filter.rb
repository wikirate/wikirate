include_set Abstract::FilterFormgroups
include_set Abstract::Utility

def advanced_filter_keys
  []
end

# def search_wql type_id, opts, params_keys, return_param=nil, &block
#   wql = { type_id: type_id }
#   wql[:return] = return_param if return_param
#   Filter.new(filter_keys_with_values, Env.params[:sort], wql, &wql).to_wql
# end

format :html do
  def sort_options
    { "Alphabetical" => "name" }
  end

  def filter_fields slot_selector: nil, sort_field: nil
    form_args = { action: filter_action_path, class: "slotter" }
    form_args["data-slot-selector"] = slot_selector if slot_selector
    filter_form filter_form_data, sort_field, form_args
  end

  def filter_form_data
    all_filter_keys.each_with_object({}) do |cat, h|
      h[cat] = { label: filter_label(cat),
                 input_field: _render("#{cat}_formgroup"),
                 active: show_filter_field?(cat) }
    end
  end

  def show_filter_field? field
    filter_hash[field]
  end
end
