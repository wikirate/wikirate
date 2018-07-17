class Answer
  module Filter
    def filter filter_args
      @filter_args = filter_args
      prepare_filter
    end

    def to_name
      # [:wikirate_company, : ]
    end

    def prepare_filter
      filter_args[:company_name]
    end
  end
end
