class Card
  class VegaChart
    module Helper
      # default axis configuration for vega charts
      module Subgroup
        GROUP_PATHS = {
          value_type: "Value_Type.json",
          metric_type: "/Metric_Type+*type+by_create.json"
        }

        def hash
          with_values year_list: 1 do
            super.tap do |h|
              h[:legends] = [builtin(:subgroup_legend)]
              h[:scales] ||= []
              h[:scales] << builtin(:subgroup_scale)
              add_filter h[:data]
              add_group_data_url h[:data]
            end
          end
        end

        def filter_data_index
          -1
        end

        def add_group_data_url data_array
          data_array.first[:url] = format.card_url GROUP_PATHS[filter_key]
        end

        def add_filter data_array
          data_array[filter_data_index][:transform] <<
            { type: "formula", as: "filter", expr: "{ #{filter_key}: datum.group }" }
        end

        def filter_key
          :metric_type
        end
      end
    end
  end
end
