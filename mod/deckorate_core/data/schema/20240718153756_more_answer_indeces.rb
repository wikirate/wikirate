# -*- encoding : utf-8 -*-

class MoreAnswerIndeces < Cardio::Migration::Schema
  def up
    add_index :answers, %i[company_id year unpublished],
              name: "company_year_unpublished_index"
    add_index :answers, %i[metric_id year unpublished],
              name: "metric_year_unpublished_index"
    add_index :answers, %i[company_id metric_id year unpublished],
              name: "company_metric_year_unpublished_index"
  end
end
