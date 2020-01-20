# -*- encoding : utf-8 -*-

class NewBrowseFilters < Card::Migration
  def up
    ensure_code_card "browse research group filter"
    ensure_code_card "browse project filter"

    update_counts :research_group, :researcher, :project
    update_counts :project, :metric, :wikirate_company, :subproject
    update_counts :wikirate_topic, :research_group
  end

  def update_counts type, *fields
    Card.search(type: type) do |base|
      fields.each do |trait|
        base.fetch(trait, new: {}).update_cached_count
      end
    end
  end
end
