module LookupTable
  # handle the "latest flag"
  #
  # including module should define "#latest_context", which returns a relationship
  # representing the records out of which one should be flagged as latest
  module Latest
    # fetcher method for latest field
    # @return [True/False]
    def fetch_latest
      return true unless (latest_year = latest_year_in_db)
      year = fetch_year
      @new_latest = year if latest_year < year
      latest_year <= year
    end

    def latest= value
      latest_to_false if @new_latest # explain via comment
      super
    end

    # @return [Integer] year of latest answer
    def latest_year_in_db
      latest_context.maximum :year
    end

    def latest_to_false
      with_latest_year do |year|
        latest_context.where.not(year: year).update_all latest: false
      end
    end

    def latest_to_true
      with_latest_year do |year|
        latest_context.where(year: year, latest: false).update_all latest: true
      end
    end

    def with_latest_year
      (latest_year = @new_latest || latest_year_in_db) && yield(latest_year)
    end
  end
end
