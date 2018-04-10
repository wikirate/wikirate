# -*- encoding : utf-8 -*-

class CorrectAnswerNames < Card::Migration
  disable_ddl_transaction!

  def up
    Answer.in_batches do |answers|
      answers.each do |a|
        company = Card.fetch_name(a.company_id).to_s
        metric =  Card.fetch_name(a.metric_id).to_s
        if company != a.company_name || metric != a.metric_name
          a.update_attributes! company_name: company, metric_name: metric
        end
      end
    end
  end
end
