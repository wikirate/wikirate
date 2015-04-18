
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
  view :titled_with_edits do |args|
    wrap args do
      [
        _render_header( args ),
        render_edits_by( args ),
        wrap_body( :content=>true ) { _render_core args },
      ]
    end
  end

  view :edit_without_title do |args|

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
    href = "#{ href_root }##{ card.cardname.url_key }"
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
    tag_filter_spec filter_words, extra.merge(:type=>'claim'), %w( tag company topic )
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
