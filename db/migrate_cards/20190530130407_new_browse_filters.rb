# -*- encoding : utf-8 -*-

class NewBrowseFilters < Cardio::Migration
  def up
    update_counts :research_group, :researcher, :project
    update_counts :project, :metric, :wikirate_company, :subproject
    update_counts :wikirate_topic, :research_group
  end

  def update_counts type, *fields
    Card.search(type: type) do |base|
      fields.each do |trait|
        base.fetch(trait, new: {}).update_cached_count_without_callbacks
      end
    end
  end
end
