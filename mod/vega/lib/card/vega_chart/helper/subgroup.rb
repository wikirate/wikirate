class Card
  class VegaChart
    module Helper
      # default axis configuration for vega charts
      module Subgroup
        GROUP_PATHS = {
          value_type: "Value_Type.json",
          metric_type: "/Metric_Type+*type+by_create.json"
        }.freeze

        def initialize format, opts={}
          @group = opts[:group]
          super
        end

        def hash
          with_values "#{@group}_counts" => 1 do
            super.tap do |h|
              h[:legends] = [builtin(:subgroup_legend)]
              h[:scales] ||= []
              h[:scales] << builtin(:subgroup_scale)
              add_group_data h[:data]
            end
          end
        end

        def filter_data_index
          -1
        end

        def add_group_data data_array
          data_array.first[:url] = data_url
          data_array[filter_data_index][:transform] << filter_transform
        end

        def data_url
          format.card_url GROUP_PATHS[@group]
        end

        def filter_transform
          { type: "formula", as: "filter", expr: "{ #{@group}: datum.group }" }
        end
      end
    end
  end
end
