# -*- encoding : utf-8 -*-

class AddAndRenameBrowseFilter < Card::Migration
  def up
    update_existing_filter_cards
    create_new_filter_cards
    import_cards "import_browse_notes_and_sources.json"
  end

  def update_existing_filter_cards
    %w(metric topic company).each do |name|
      next unless (card = Card["filter_search_#{name}".to_sym])
      card.update_attributes! name: "browse #{name} filter",
                              codename: "browse_#{name}_filter",
                              update_referers: true
    end
  end

  def create_new_filter_cards
    ensure_card "browse note filter", codename: "browse_note_filter",
                                      type_id: Card::SearchTypeID
    ensure_card "browse source filter", codename: "browse_source_filter",
                                        type_id: Card::SearchTypeID
  end
end
