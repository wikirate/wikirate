class Card
  class AllAnswerQuery
    def initialize filter, sorting, paging
      @filter = filter.clone
      @filter.delete :status # if we are here this is "all"
      @sorting = wqlize_sort sorting
      @paging = paging || {}

      @base_card = Card[@filter.delete(base_key)]
      @year = @filter.delete :year
    end

    # @return array of metric answer card objects
    #   if filtered by missing values then the card objects
    #   are newly instantiated and not in the database
    def run
      all_subject_ids.map do |id|
        fetch_answer id
      end
    end

    def search_wql
      @search_wql ||= subject_wql.merge(filter_wql).merge(sort_wql)
    end

    def sort_wql
      @sorting
    end

    def subject_wql
      @paging.merge(type_id: subject_type_id)
    end

    def all_subject_ids
      Card.search search_wql.merge(return: :id)
    end

    def fetch_answer id
      fetch_existing_answer(id) || fetch_missing_answer(id)
    end

    def fetch_existing_answer id
      Answer.fetch(existing_where_args.merge(subject_key => id)).first
    end

    def fetch_missing_answer id
      Card.new name: new_name(id), type_id: MetricAnswerID
    end

    def existing_where_args
      return @where_args if @where_args

      @where_args = { base_key => @base_card.id }
      if !@year || @year.to_sym == :latest
        @where_args[:latest] = true
      else
        @where_args[:year] = @year
      end
      @where_args
    end

    def where additional_filter={}
      Answer.where where_args(additional_filter)
    end

    def count
      Card.search(search_wql.merge(return: :count))
    end

    def value_count additional_filter={}
      where(additional_filter).select(:value).uniq.count
    end

    def limit
      @paging[:limit]
    end

    def new_name_year
      @new_name_year ||= year.to_s == "latest" ? Time.now.year : year
    end

    def wqlize_sort sort_hash
      sort_hash ||= {}
      { sort: sort_hash[:sort_by], dir: sort_hash[:sort_order] }
    end

    private

    def year
      @year || Time.now.year
    end
  end
end
