class Answer
  # handle the "latest" flag
  module Latest
    # fetcher method for latest field
    # @return [True/False]
    def fetch_latest
      return true unless (latest_year = latest_year_in_db)
      new_latest = latest_year <= fetch_year
      handle_latest_in_answer latest_year, new_latest
      new_latest
    end

    # other answers in same record
    def latest_context
      self.company_id ||= fetch_company_id
      self.metric_id ||= fetch_metric_id
      ::Answer.where(company_id: company_id, metric_id: metric_id).where.not(id: id)
    end

    def handle_latest_in_answer latest_year, new_latest
      if new_latest && !latest # changed from not latest to latest
        latest_to_false
      elsif latest && !new_latest # changed from latest to not latest
        latest_to_true latest_year
      end
    end

    # @return [Integer] year of latest answer
    def latest_year_in_db
      latest_context.maximum :year
    end

    def latest_to_false
      latest_context.update_all latest: false
    end

    def latest_to_true year=nil
      year ||= latest_year_in_db
      latest_context.where(year: year, latest: false).update_all latest: true if year
    end
  end
end
