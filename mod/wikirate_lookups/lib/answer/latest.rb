class Answer
  # Methods for "latest" flag
  module Latest
    def fetch_latest
      return true unless (latest_year = latest_year_in_db)
      @new_latest = (latest_year < fetch_year)
      latest_year <= fetch_year
    end

    def latest_year_in_db
      record_answers.maximum :year
    end

    # other answers in same record
    def record_answers
      self.company_id ||= fetch_company_id
      self.metric_id ||= fetch_metric_id
      Answer.where(company_id: company_id, metric_id: metric_id).where.not(id: id)
    end

    def latest_to_false
      record_answers.where(latest: true).update_all latest: false
    end

    def latest_to_true
      return unless (latest_year = latest_year_in_db)
      record_answers.where(year: latest_year, latest: false).update_all latest: true
    end

    def latest= value
      latest_to_false if @new_latest
      super
    end
  end
end
