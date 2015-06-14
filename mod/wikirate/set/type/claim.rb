# changes label of name on claims (should be obviatable)

card_accessor :vote_count, :type=>:number, :default=>"0"
card_accessor :upvote_count, :type=>:number, :default=>"0"
card_accessor :downvote_count, :type=>:number, :default=>"0"
card_accessor :direct_contribution_count, :type=>:number, :default=>"0"
card_accessor :contribution_count, :type=>:number, :default=>"0"

def indirect_contributor_search_args
  [
    {:right_id=>VoteCountID, :left=>self.name }
  ]
end


event :vote_on_create_claim, :on=>:create, :after=>:store, :when=> proc{ |c| Card::Auth.current_id != Card::WagnBotID } do
  Auth.as_bot do
    vc = vote_count_card
    vc.vote_up
    vc.supercard = self
    vc.save!
  end
end


format :html do
  view :name_formgroup do |args|
    #rename "name" to "Claim"
    #add a div for claim word counting
    %{
      #{ formgroup 'Claim', raw( name_field form ), :editor=>'name', :help=>true }
      <div class='claim-counting'>
        <span class='claim-counting-number'>100</span> character(s) left
      </div>
    }
  end

  view :citation_and_content do |args|
    output([
      render_citation_or_cite_button(args),
      render_content(args)
    ])
  end

  view :citation_or_clipboard do |args|
    args[:citation_number] || optional_render( :clipboard, args )
  end

  view :citation_or_cite_button do |args|
    args[:citation_number] || optional_render( :cite_button, args )
  end

  view :cite_button do |args|
    if parent.parent.present? and parent.parent.card.present?
      article_name = parent.parent.card.cardname.url_key
      url = "/#{article_name}?citable=#{card.cardname.url_key}&edit_article=true"
      link_to 'Cite!', url, :class=>"cite-button"
    else
      ""
    end
  end

  view :new do |args|
    #hide all help text under title
    super args.merge( :optional_help => :hide )
  end

  def edit_slot args
    # :core_edit means the new and edit views will render form fields from within the core view
    # (which in this case is defined by Claim+*type+*structure), as opposed to the default behavior,
    # which is to strip out the inclusions and render them alone.
    super args.merge( :core_edit=>true )
  end


  view :tip, :perms=>:none, :closed=>:blank do |args|
    # special view for prompting users with next steps
    if Auth.signed_in? and ( tip = args[:tip] || next_step_tip ) and @mode != :closed
      %{
        <div class="claim-tip">
          Tip: You can #{ tip }
          <span id="close-tip" class="fa fa-times-circle"></span>
        </div>
      }
    end.to_s
  end

  def next_step_tip
    if (not topics = Card["#{card.name}+topics"]) || topics.item_names.empty?
      "improve this claim by adding a topic."
    elsif (not companies = Card["#{card.name}+company"]) || companies.item_names.empty?
      "improve this claim by adding a company."
    else
      cited_in = Card.search :refer_to => card.name, :left=>{:type=>'Analysis'}, :right=>{:name=>'article'}
      if card.analysis_names.size > cited_in.size
        "cite this claim in related articles."
      end
    end
  end

  view :sample_citation do |args|
    tip = "easily cite this claim by pasting the following:" +
      text_area_tag( :citable_claim, card.default_citation )
    %{ <div class="sample-citation">#{ render :tip, :tip=>tip }</div> }
  end

  view :titled, :tags=>:comment do |args|
    render_titled_with_voting args
  end

  view :open do |args|
    super args.merge( :custom_claim_header=>true, :optional_horizontal_menu=>:hide )
  end

  view :header do |args|
    if args[:custom_claim_header]
      render_haml(:args=>args) do
        %{
.header-with-vote
  .header-vote
    = subformat( card.vote_count_card ).render_details
  .header-citation
    = nest card.fetch(:trait=>:citation_count), :view=>:titled, :hide=>"menu", :title=>"Citations"
  .header-title
    %h1.card-header
      = _optional_render :toggle, args, :hide
      %i.fa.fa-quote-left
      = _optional_render :title, args
      %i.fa.fa-quote-right
    .creator-credit
      = nest card, :structure=>"creator credit"
.clear-line
        }
      end
    else
      super(args)
    end
  end
end


def analysis_names
  if topics   = Card["#{name}+#{Card[:wikirate_topic  ].name}"] and
    companies = Card["#{name}+#{Card[:wikirate_company].name}"]

    companies = companies.item_cards.reject { |c| c.new_card? || c.type_id != Card::WikirateCompanyID }
    topics    = topics   .item_cards.reject { |c| c.new_card? || c.type_id != Card::WikirateTopicID   }

    companies.map do |company|
      topics.map do |topic|
        "#{company.name}+#{topic.name}"
      end
    end.flatten
  end
end

event :reset_claim_counts, :after=>:store do
  Card.reset_claim_counts
end


event :validate_claim, :before=>:approve, :on=>:save do
  errors.add :claim, "is too long (100 character maximum)" if name.length > 100
end

event :validate_source, :after=>:approve, :on=>:save do
  # 1. it correctly validates when adding a claim
  # 2. it correctly validates when editing a claim with +source
  # 3. it doesn't break anything when editing a claim without +source (eg renaming)

  #first, get the source card from request
  source_card = subcards["+source"]||subcards["+Source"]

  if source_card || new_card?
    check_source source_card
  end
end

def check_source source_card

  if !source_card or !source_card.content.present?
    errors.add :source, "is empty"
  else
    source_card.item_cards.each do |item_card|
      if !item_card.real?
        errors.add :source, "#{item_card.name} does not exist"
      elsif item_card.type_id != Card::SourceID
        errors.add :source, "#{item_card.name} is not a valid Source Page"
      end
    end
  end
end

view :missing do |args|
  _render_link args
end

view :clipboard do |args|
  %{
    <i class="fa fa-clipboard claim-clipboard" id="copy-button" title="copy claim citation to clipboard" data-clipboard-text="#{h card.default_citation}"></i>
  }
end



def default_citation
  "#{name} {{#{name}|cite}}"
end


=begin
event :sort_tags, :before=>:approve_subcards, :on=>:create do
  tag_key = "+tags" #FIXME - hardcoded card name
  if tags_card = subcards[tag_key]
    tags_card.item_names.each do |tag|
      if tag_card = Card.fetch( tag )
        if tagtype = tag_card.type_code and [ :wikirate_company, :wikirate_topic ].member?(tagtype)
          type_key = "+#{ Card[tagtype].name }"
          subcards[type_key] ||= Card.new :name=>type_key, :supercard=>self, :type_id=>Card::PointerID
          subcards[type_key].add_item tag
          tags_card.drop_item tag
        end

      end
    end
  end
end
=end

