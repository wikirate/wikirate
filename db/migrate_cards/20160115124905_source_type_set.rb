# -*- encoding : utf-8 -*-

class SourceTypeSet < Card::Migration
  def source_types_list
    %w( Link File Text ).map do |type|
      "[[#{type}]]"
    end.join "\n"
  end

  def up
    create_source_type_card
    create_source_type_set_rule
    update_create_rule
    Card::Cache.reset_global
    update_existing_source_cards

    import_json 'source_set_type.json'

  end

  def update_existing_source_cards
    all_source_cards = Card.search type_id: Card::SourceID
    all_source_cards.each do |sc|
      sc_st = sc.fetch(trait: :source_type, new: {})
      sc_st.content = ''
      type =
        if sc.fetch(trait: :wikirate_link)
          'Link'
        elsif sc.fetch(trait: :file)
          'File'
        elsif sc.fetch(trait: :text)
          'Text'
        end
      sc_st.add_item! type
    end
  end

  def create_source_type_set_rule
    create_card! name: 'source type+*source type+*type plus right+*structure',
                 type_id: Card::SetID,
                 content: '{"type":"source",' \
                          '"right_plus":["*source type",{"refer_to":"_left"}]}'
  end

  def update_create_rule
    create_card! name: 'source+*source_type+*type plus right+*create',
                 content: '_left'
  end

  def create_source_type_card
    create_card! name: '*source type', codename: 'source_type',
                 subcards: {
                   '+*right+*default' => {
                     type_id: Card::PointerID,
                     content: '[[Link]]'
                   },
                   '+*right+*options' => {
                     type_id: Card::PointerID,
                     content: source_types_list
                   },
                   '+*right+*input' => {
                     content: 'radio'
                   },
                 }
  end
end
