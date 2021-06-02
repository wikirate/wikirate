class Card
  class LookupFilterQuery
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
  end
end
