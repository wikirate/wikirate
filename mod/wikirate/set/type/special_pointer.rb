include Card::Set::Type::Pointer 

format do
  include Card::Set::Type::Pointer::Format
end

format :html do
  include Card::Set::Type::Pointer::HtmlFormat 
end

format :json do
  def get_list_of_children_and_self c
    [
      nest(c),
      Card.search(:left=>c.name).map do |ec|
        nest(ec)
      end,
      Card.search(:included_by=>c.name).map do |ec|
        nest(ec)
      end
    ]
  end
  def lite_render args
    card.item_cards.map do |c|
      case c.type_id
      when Card::SearchTypeID
        [
          nest(c),
          c.item_names.map do |cs|
            nest(cs)
          end
        ]
      else
        nest(c)
      end
    end.flatten.reject { |c| c.nil? || c.empty? }
  end 
  def advance_render args
    card.item_cards.map do |c|
      case c.type_id
      when Card::SearchTypeID
        [
          nest(c),
          c.item_names.map do |cs|
            if search_card_item = Card[cs]
              get_list_of_children_and_self search_card_item
            end
          end
        ]
      when Card::SpecialPointerID
        [
          nest(c),
          c.format(:json).render_core(args)
        ]
      when Card::PointerID
        [
          nest(c),
          c.item_cards.map do |c|
            get_list_of_children_and_self c
         end
        ]
      else
        get_list_of_children_and_self c   
      end
    end.flatten.reject { |c| c.nil? || c.empty? }
  end
  view :core do |args|
    if Env::params["lite"] == "true"
      lite_render args
    else
      advance_render args
    end
    
  end
end
  