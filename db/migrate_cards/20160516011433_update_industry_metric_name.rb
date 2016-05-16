# -*- encoding : utf-8 -*-

class UpdateIndustryMetricName < Card::Migration
  def up
    industry_metric = Card['Richard Mills+Sector Industry']
    industry_metric.name = 'Global Reporting Initiative+Sector Industry'
    industry_metric.update_referers = true
    industry_metric.save!
  end
end
