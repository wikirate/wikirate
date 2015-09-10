
format :json do

  def get_migration_records table_name
    sql = "SELECT * FROM #{table_name}"
    ActiveRecord::Base.connection.execute(sql).each.each.map do |record|
      record[0]
    end
  end
  view :content do |args|

    result = super args
    migration_record = {}
    ["schema_migrations","schema_migrations_cards","schema_migrations_core_cards","schema_migrations_deck_cards"].each do |table|
      migration_record[table] = get_migration_records table  
    end
    result["migration_record"] = migration_record
    result
  end

  def get_pointer_items c, count=0
    count += 1
    # avoid infinit recursive
    return nil if count > 10
    c.item_cards.map do |item_card|
      if item_card.type_id == Card::PointerID || item_card.type_id == Card::SkinID
        [
          nest(item_card),
          get_pointer_items(item_card,count)
        ]
      else
        nest item_card
      end
    end.flatten
  end
  def export_render args
    card.item_cards.map do |c|
      begin
        case c.type_id
        when Card::SearchTypeID
          # avoid running the search from options and structure that casue a huge result or error
          if  c.content.empty? || c.name.include?("+*options") ||c.name.include?("+*structure")
            nest(c)
          else
            # put the search results into the export
            [
              nest(c),
              c.item_names.map do |cs|
                nest(cs)
              end
            ]
          end
        when Card::PointerID, Card::SkinID
          [
            nest(c),
            # recursively getting pointer items
            get_pointer_items(c)
          ]

        else
          nest c   
        end
      rescue => e
        Rails.logger.info "Fail to get the card #{c} reason:#{e}"
      end
    end.flatten.reject { |c| (c.nil? || c.empty?) }
  end
  view :core do |args|
    if Env::params["export"] == "true"
      export_render args
    else
      super args
    end
    
  end
end
