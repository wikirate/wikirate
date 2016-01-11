
require "net/https"
require "uri"
format do

  view :cite, :closed=>true do |args|
    ''
  end

  view :raw_or_blank, :perms=>:none, :closed=>true do |args|
    _render(:raw) or ''
  end
end


format :html do

  view :cgi_escape_name do |args|
    CGI::escape card.name
  end

  view :og_source, :tags=>:unknown_ok do |args|
    if card.real?
      card.format.render_source
    else
      Card["*Vertical_Logo"].format.render_source args.merge({:size=>"large"})
    end
  end

  view :meta_preview do |args|
    ActionView::Base.full_sanitizer.sanitize(Card::Content.truncatewords_with_closing_tags _render_core(args), words=50)
  end

  def is_number? str
    true if Float(str) rescue false
  end

  view :progress_bar do |args|
    value = card.raw_content
    if is_number? value
      %{
        <div class="progress">
          <div class="progress-bar" role="progressbar" aria-valuenow="#{value}" aria-valuemin="0" aria-valuemax="100" style="width: #{value}%;">#{value}%</div>
        </div>
      }
    else
      "Only card with numeric content can be shown as progress bar."
    end
  end

  view :titled_with_edits do |args|
    wrap args do
      [
        _render_header( args ),
        render_edits_by( args ),
        wrap_body( :content=>true ) { _render_core args },
      ]
    end
  end

  view :edits_by do |args|
    editor_card = card.fetch :trait=>:editors
    %{
      <div class="edits-by">
        <div class='subtitle-header'>Edits by</div>
        #{ subformat( editor_card).render_shorter_search_result :item=>:link}
      </div>
    }
  end


  view :open do |args|
    super(args.reverse_merge :optional_horizontal_menu=>:show)
  end

  attr_accessor :citations


  def default_menu_link_args args
    args[:menu_icon] = 'edit'
  end

  def default_menu_args args
    args[:optional_horizontal_menu] ||= :show if main?
  end

  view :shorter_search_result do |args|
    items = card.item_cards :limit=>0
    total_number = items.size
    fetch_number = [total_number, 4].min

    result = ''
    if fetch_number > 1
      result += items[0..fetch_number-2].map do |c|
        subformat(c).render(:link)
      end.join(' , ')
      result += ' and '
    end

    result += if total_number > fetch_number
        "<a class=\"known-card\" href=\"#{card.format.render(:url)}\"> #{total_number-3} others</a>"
      else
        subformat(items[fetch_number-1]).render(:link)
      end
  end

  view :name_formgroup do |args|
    #force showing help text
    args[:help] ||= true
    super args
  end


  view :cite do |args|
    href_root = parent ? parent.card.cardname.trunk_name.url_key : ''
    href = "##{ card.cardname.url_key }"
    %{<sup><a class="citation" href="#{ href }">#{ cite! }</a></sup>}
  end


  def cite!
    holder = parent.parent || parent || self
    holder.citations ||= []
    holder.citations << card.key
    holder.citations.size
  end

  view :wikirate_modal do |args|
    card_name = Card::Env.params[:show_modal]
    if card_name.present?
      after_card = Card[card_name]
      if !after_card
         Rails.logger.info "Expect #{card_name} exist"
         "" #otherwise it will return true
      else
         "<div class='modal-window'>#{ subformat( after_card ).render_core } </div>"
      end
    else
      ""
    end
  end

  view :yinyang_list do |args|
    content_tag :div, :class=>"yinyang-list #{args[:yinyang_list_class]}" do
      _render_yinyang_list_items(args)
    end
  end

  view :showcase_list, :tags=>:unknown_ok do |args|
    item_type_name = card.cardname.right.split.last
    icon_card = Card.fetch("#{item_type_name}+icon")
    wrap args.merge(:slot_class=>"showcase #{'hidden' if card.content.empty?}") do
      %{
        #{subformat(icon_card)._render_core}
        #{item_type_name.capitalize}
        #{_render_core(args)}
      }
    end
  end

  view :open_contribution_list do |args|
    _render_open(args.merge(:contribution_list=>true))
  end

  view :header do |args|
    if args.delete(:contribution_list)
      view :header do |args|
        %{
          <div class="card-header #{ args[:header_class] }">
            <div class="card-header-title #{ args[:title_class] }">
              #{ _optional_render :title, args }
              #{ _optional_render :contribution_counts, args }
              #{ _optional_render :toggle, args, :hide }
            </div>
          </div>
          #{ _optional_render :toolbar, args, :hide}
        }
      end
    else
      super(args)
    end
  end

  view :yinyang_list_items do |args|
    item_args = { :view => ( args[:item] || (@inclusion_opts && @inclusion_opts[:view]) || default_item_view ) }
    joint = args[:joint] || ' '

    if type = card.item_type
      item_args[:type] = type
    end

    enrich_result(card.item_names).map do |icard|
      content_tag :div, :class=>"yinyang-row" do
       nest(icard, item_args.clone).html_safe
      end.html_safe
    end.join(joint).html_safe
  end

  def enrich_result result
    result.map do |item_name|
       # 1) add the main card name on the left
       # for example if "Apple+metric+*upvotes+votee search" finds "a metric" we add "Apple" to the left
       # because we need it to show the metric values of "a metric+apple" in the view of that item
       # 2) add "yinyang drag item" on the right
       # this way we can make sure that the card always exists with a "yinyang drag item+*right" structure
      Card.fetch "#{main_name}+#{item_name}+yinyang drag item"
    end
  end

  def main_name
    @main_name ||= card.cardname.left_name.left
  end

  def main_type_id
    @main_type_id ||= Card.fetch(main_name).type_id
  end

  def searched_type_id
    @searched_type_id ||= Card.fetch_id card.cardname.left_name.right
  end

end

CLAIM_SUBJECT_SQL = %{
  select subjects.`key` as subject, claims.id from cards claims
  join cards as pointers on claims.id   = pointers.left_id
  join card_references   on pointers.id = referer_id
  join cards as subjects on referee_id  = subjects.id
  where claims.type_id =    #{ Card::ClaimID }
  and pointers.right_id in (#{ [ Card::WikirateTopicID, Card::WikirateCompanyID ] * ', ' })
  and claims.trash   is false
  and pointers.trash is false
  and subjects.trash is false;
}

module ClassMethods



  def claim_count_cache
    Card::Cache[Card::Set::Right::WikirateClaimCount]
  end

  def claim_counts subj
    ccc = claim_count_cache
    ccc.read subj  or begin
      subjname = subj.to_name
      count = claim_subjects.find_all do |id, subjects|
        if subjname.simple?
          subjects_apply? subjects, subj
        else
          subjects_apply? subjects, subjname.left and subjects_apply? subjects, subjname.right
        end
      end.size
      ccc.write subj, count
    end
  end

  def subjects_apply? references, test_list
    !!Array.wrap(test_list).find do |subject|
      references.member? subject
    end

  end

  def claim_subjects
    ccc = claim_count_cache
    ccc.read 'CLAIM-SUBJECTS' or begin
      hash = {}
      sql =
      ActiveRecord::Base.connection.select_all( CLAIM_SUBJECT_SQL ).each do |row|
        hash[ row['id'] ] ||= []
        hash[ row['id'] ] << row['subject']
      end
      ccc.write 'CLAIM-SUBJECTS', hash
    end
  end

  def reset_claim_counts
    claim_count_cache.reset hard=true
  end

  def tag_filter_query filter_words, extra={}, tag_types=['tag']
    filter_words = [filter_words] unless Array === filter_words
    search_args = filter_words.inject({}) do |res, filter|
     hash = {}
     hash['and'] = res unless res.empty?
     hash.merge(
         { 'right_plus' =>
               if tag_types.size > 1
                 [{'name' => ['in'] + tag_types}, 'refer_to'=>filter]
               else
                 [tag_types.first, 'refer_to'=>filter]
               end
         }
      )
    end
    search_args.merge(extra)
  end

  def claim_tag_filter_spec filter_words, extra={}
    tag_filter_spec filter_words, extra.merge(:type_id=>ClaimID), %w( tag company topic )
  end
end




format :json do

  view :content do |args|
    result = super args
    result[:card][:value].reject! { |c| c==nil }
    result
  end
  view :id_atom do |args|
    if !params['start'] or (params['start'] and start = params['start'].to_i and card.updated_at.strftime("%Y%m%d%H%M%S").to_i >= start )
      h = _render_atom
      h[:id] = card.id  if card.id
      h
    else
      nil
    end
  end

end
