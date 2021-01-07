class Answer
  # Methods for "latest" flag
  module Latest




    # other answers in same record
    def latest_context
      self.company_id ||= fetch_company_id
      self.metric_id ||= fetch_metric_id
      Answer.where(company_id: company_id, metric_id: metric_id).where.not(id: id)
    end






  end
end
