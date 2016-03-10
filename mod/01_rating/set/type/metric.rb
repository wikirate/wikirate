card_accessor :vote_count, type: :number, default: '0'
card_accessor :upvote_count, type: :number, default: '0'
card_accessor :downvote_count, type: :number, default: '0'

format :html do
  view :legend do |_args|
    # depends on the type
    if (unit = Card.fetch("#{card.name}+unit"))
      unit.raw_content
    elsif (range = Card.fetch("#{card.name}+range"))
      "/#{range.raw_content}"
    else
      ''
    end
  end

  def view_caching?
    true
  end

  view :value_type_edit_modal_link do |args|
    value_type_card = card.fetch trait: :value_type, new: {}
    subformat_card = subformat(value_type_card)
    text =
      if value_type_card.new?
        'Update Value Type'
      else
        subformat_card.render(:shorter_pointer_content)
      end
    edit_args = {
      path_opts: {
        slot: {
          hide: 'title,header,menu,help,subheader',
          view: :edit, edit_value_type: true
        }
      },
      html_args: {
        class: 'btn btn-default slotter'
      },
      text: text
    }
    render_modal_link(args.merge(edit_args))
  end

  view :short_view do |_args|
    return '' unless (value_type = Card["#{card.name}+value type"])
    subcard_name =
      case value_type.item_names[0]
      when 'Number'
        'numeric_details'
      when 'Monetary'
        'monetary_details'
      when 'Category'
        'category_details'
      end
    return '' if subcard_name.nil?
    detail_card = Card.fetch "#{card.name}+#{subcard_name}"
    subformat(detail_card).render_content
  end

  def default_edit_args args
    edit_args args
    super(args)
  end

  def edit_args args
    return unless args[:edit_value_type]
    args[:structure] = 'metric value type edit structure'
  end

  def edit_slot args
    if args[:edit_value_type]
      super args.merge(core_edit: true)
    else
      super args
    end
  end
end

def analysis_names
  return [] unless (topics = Card["#{name}+#{Card[:wikirate_topic].name}"]) &&
                   (companies = Card["#{name}+#{Card[:wikirate_company].name}"])

  companies.item_names.map do |company|
    topics.item_names.map do |topic|
      "#{company}+#{topic}"
    end
  end.flatten
end
