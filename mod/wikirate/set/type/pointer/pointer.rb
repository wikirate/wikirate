view :solocomplete do |args|
  args ||= {}
  items = args[:item_list] || card.item_names(:context=>:raw)
  items = [''] if items.empty?
  options_card_name = (oc = card.options_rule_card) ? oc.cardname.url_key : ':all'

  extra_css_class = args[:extra_css_class] || 'pointer-list-ul'

  %{
    <ul class="pointer-list-editor #{extra_css_class}" data-options-card="#{options_card_name}">
      <li class="pointer-li">
      <span class="input-group">
        #{ text_field_tag 'pointer_item', items[0], :class=>'pointer-item-text form-control' }
      </span>
      </li>
    </ul>
  }
end

format :json do
  def get_pointer_items c, count=0
    count += 1
    # avoid infinit recursive
    return nil if count > 10
    c.item_cards.map do |item_card|
      if item_card.type_id == Card::PointerID
        get_pointer_items item_card,count
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
        when Card::PointerID
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
