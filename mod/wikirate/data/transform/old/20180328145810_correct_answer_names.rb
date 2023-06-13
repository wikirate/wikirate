# -*- encoding : utf-8 -*-

class CorrectAnswerNames < Cardio::Migration::Transform
  disable_ddl_transaction!

  def up
    Answer.in_batches do |answers|
      answers.each do |a|
        company = Card.fetch_name(a.company_id).to_s
        metric =  Card.fetch_name(a.metric_id).to_s
        if company != a.company_name || metric != a.metric_name
          begin
            a.update! company_name: company, metric_name: metric
          rescue => e
            puts "error updating answer #{a.id}: #{e.message}"
          end
        end
      end
    end
  end
end
