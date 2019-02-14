class Answer
  # Methods for "latest" flag
  module Latest
    def latest_year_in_db
      self.record_id ||= fetch_record_id
      Answer.where(record_id: record_id).where.not(id: id).maximum :year
    end

    def latest_to_false
      Answer.where(record_id: record_id, latest: true).where.not(id: id)
            .update_all(latest: false)
    end

    def latest_to_true
      return unless (latest_year = latest_year_in_db)
      Answer.where(record_id: record_id, year: latest_year, latest: false)
            .update_all latest: true
    end

    def latest= value
      latest_to_false if @new_latest
      super
    end
  end
end
