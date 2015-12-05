card_accessor :vote_count, :type=>:number, :default=>"0"
card_accessor :upvote_count, :type=>:number, :default=>"0"
card_accessor :downvote_count, :type=>:number, :default=>"0"

card_accessor :metric_type,
              :type=>:pointer, :default=>"[[Researched]]"



def metric_type
  metric_type_card.item_names.first
end

def metric_type_codename
  Card[metric_type].codename
end

    # def value company, year
#   (value_card = Card["#{name}+#{company}+#{year}+#{value}"]) &&
#     value_card.content
# end

def create_value args
  missing = [:company, :year, :value].reject { |v| args[v] }
  if missing.present?
    errors.add 'metric value', "missing #{missing.to_sentence}"
    return
  end
  create_args = {
    name: "#{name}+#{args[:company]}+#{args[:year]}",
    type_id: Card::MetricValueID,
    '+value' => args[:value]
  }
  if metric_type_codename == :reseached
    if !args[:source]
      errors.add 'metric value', "missing source"
      return
    end
    create_args[:source] = args[:source]
  end
  Card.create! create_args
end

def companies_with_years_and_values
  Card.search(right: 'value', left: {
    left: { left: card.name },
    right: { type: 'year' }
    }).map do |card|
    [card.cardname.left_name.left_name.right, card.cardname.left_name.right, card.content]
  end
end

def random_value_card
  Card.search(right: 'value',
              left: {
                left: { left: name },
                right: { type: 'year' }
              },
              limit: 1).first
end

def random_company_card_with_value
  return unless rvc = random_value_card
  rvc.left.left.right
end

format :html do
  view :legend do |args|
    if (unit = Card.fetch("#{card.name}+unit"))
      unit.raw_content
    elsif (range = Card.fetch("#{card.name}+range"))
      "/#{range.raw_content}"
    else
      ''
    end
  end

  view :item_view do |args|
    handle =
      if args[:draggable]
        <<-HTML
          <div class="handle">
            <span class="glyphicon glyphicon-option-vertical"></span>
          </div>
        HTML
      end

    value =
      if args[:company]
        <<-HTML
          <div class="data-item hide-with-details">
            {{#{card.name}+#{args[:company]}+latest value|concise}}
          </div>
        HTML
      end

    vote =
      if args[:vote]
        %(<div class="hidden-xs hidden-md">{{#{card.name}+*vote count}}</div>)
      end
    metric_designer = card.cardname.left
    metric_name = card.cardname.right

    html = <<-HTML
    <!--prototype: Company+MetricDesigner+MetricName+yinyang drag item -->
    <div class="yinyang-row">
    <div class="metric-item value-item">
      <div class="header metric-details-toggle" data-append="#{card.key}+add_to_formula">
        #{handle}
        #{vote}
        <div class="logo hidden-xs hidden-md">
          {{#{metric_designer}+image|core;size:small}}
        </div>
        <div class="name">
            {{#{metric_name}|name}}
        </div>
      </div>
       <div class="details">
       </div>
    </div>
  </div>
    HTML
    with_inclusion_mode :normal do
      wrap args do
        process_content html
      end
    end
  end


  view :item_view_with_value do |args|
    handle =
      if args[:draggable]
        <<-HTML
          <div class="handle">
            <span class="glyphicon glyphicon-option-vertical"></span>
          </div>
        HTML
      end

    value =
      if args[:company]
        <<-HTML
          <div class="data-item hide-with-details">
            {{#{card.name}+#{args[:company]}+latest value|concise}}
          </div>
        HTML
      end

    vote =
      if args[:vote]
        %(<div class="hidden-xs hidden-md">{{#{card.name}+*vote count}}</div>)
      end
    metric_designer = card.cardname.left
    metric_name = card.cardname.right

    html = <<-HTML
    <!--prototype: Company+MetricDesigner+MetricName+yinyang drag item -->
    <div class="yinyang-row">
    <div class="metric-item value-item">
      <div class="header">
        #{handle}
        #{vote}
        <a href="{{_llr+contributions|linkname}}">
        <div class="logo hidden-xs hidden-md">
          {{#{metric_designer}+image|core;size:small}}
        </div>
        </a>
        <div class="name">
          <a class="inherit-anchor" href="{{#{card.name}|linkname}}">
            {{#{metric_name}|name}}
          </a>
        </div>
      </div>
      <div class="data metric-details-toggle" data-append="#{card.key}+add_to_formula">
        #{value}
        <div class="data-item show-with-details text-center">
          <span class="label label-metric">[[#{card.name}|Metric Details]]</span>
        </div>
      </div>
      <div class="details">
      </div>
    </div>
  </div>
    HTML
    with_inclusion_mode :normal do
      wrap args do
        process_content html
      end
    end
  end



  def view_caching?
    true
  end
end

format :json do
  view :content do
    companies_with_years_and_values.to_json
  end
end
