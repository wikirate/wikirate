# -*- encoding : utf-8 -*-

class AddIndustryCards < Card::Migration
  def up
    merge_cards %w[industry common+industry common+industry+*metric_type
      common+industry+value_type common+industry+research_policy
      common+industry+hybrid common+industry+question  isic industry_section
      isic+industry_section isic+industry_section+*metric_type
      isic+industry_section+value_type isic+industry_section+question
      isic+industry_section+hybrid isic+industry_section+research_policy
      isic+industry_section+methodology industry_division
      isic+industry_division isic+industry_division+*metric_type
      isic+industry_division+value_type isic+industry_division+question
      isic+industry_division+hybrid isic+industry_division+research_policy
      isic+industry_division+methodology industry_group isic+industry_group
      isic+industry_group+*metric_type isic+industry_group+value_type
      isic+industry_group+question isic+industry_group+hybrid
      isic+industry_group+research_policy isic+industry_group+methodology industry_class
      isic+industry_class isic+industry_class+*metric_type isic+industry_class+methodology
      isic+industry_class+value_type isic+industry_class+research_policy
      isic+industry_class+question common+industry+formula]
  end
end
