# -*- encoding : utf-8 -*-

class UpdateIndustryMetricName < Card::Migration
  def up
    industry_metric = Card['Richard Mills+Sector Industry']
    industry_metric.name = 'Global Reporting Institute+Sector Industry'
    industry_metric.save!
  end
end
