class Card
  # base class for FilterQuery classes built on lookup tables
  class LookupFilterQuery
    include Filtering

    attr_accessor :filter_args, :sort_args, :paging_args
    class_attribute :card_id_map, :card_id_filters, :simple_filters

    def initialize filter, sorting={}, paging={}
      @filter_args = filter
      @sort_args = sorting
      @paging_args = paging

      @conditions = []
      @joins = []
      @values = []
      @restrict_to_ids = {}

      process_sort
      process_filters
    end

    def lookup_query
      q = lookup_class.where lookup_conditions
      q = q.joins(@joins.uniq) if @joins.present?
      q
    end

    def lookup_table
      @lookup_table ||= lookup_class.arel_table.name
    end

    def condition_sql conditions
      lookup_class.sanitize_sql_for_conditions conditions
    end

    def lookup_relation
      sort_and_page { lookup_query }
    end

    # @return args for AR's where method
    def lookup_conditions
      condition_sql([@conditions.join(" AND ")] + @values)
    end

    # TODO: support optionally returning lookup objects

    # @return array of metric answer card objects
    #   if filtered by missing values then the card objects
    #   are newly instantiated and not in the database
    def run
      @empty_result ? [] : main_results
    end

    # @return [Array]
    def count
      @empty_result ? 0 : main_query.count
    end

    def limit
      @paging_args[:limit]
    end

    def main_query
      @main_query ||= lookup_query
    end

    def main_results
      # puts "SQL: #{lookup_relation.to_sql}"
      lookup_relation.map(&:card)
    end

    private

    def sort_and_page
      relation = yield
      @sort_joins.uniq.each { |j| relation = relation.joins(j) }

      relation.sort(@sort_hash).paging(@paging_args)
    end

    def process_sort
      @sort_joins = []
      @sort_hash = @sort_args.each_with_object({}) do |(by, dir), h|
        h[sort_by(by)] = sort_dir(dir)
      end
    end

    def sort_by sort_by
      if (id_field = sort_by_cardname[sort_by])
        sort_by_join sort_by, lookup_table, id_field
      else
        simple_sort_by sort_by
      end
    end

    def sort_by_cardname
      {}
    end

    def sort_dir dir
      dir
    end

    def simple_sort_by sort_by
      sort_by
    end

    def sort_by_join sort_by, from_table, from_id_field
      @sort_joins <<
        "JOIN cards as #{sort_by} ON #{sort_by}.id = #{from_table}.#{from_id_field}"
      "#{sort_by}.key"
    end
  end
end
