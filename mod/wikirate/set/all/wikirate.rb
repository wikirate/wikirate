
require "net/https"
require "uri"
format do
  view :cite do |args|
    ''
  end

  view :raw_or_blank, :perms=>:none do |args|
    _render(:raw) or ''
  end
end


format :html do

  attr_accessor :citations
  
  view :menu_link do |args|
    '<a class="fa fa-pencil-square-o"></a>'
  end
  
  view :name_fieldset do |args|
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

  view :modal do |args|
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
    Wagn::Cache[Card::Set::Right::WikirateClaimCount]
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
end




format :json do
  def isIframable url,counter
    
    return false if counter>5
    begin 
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      request.initialize_http_header({"User-Agent" => "My Ruby Script"})

      response = http.request(request)
      if response.code=="301" or response.code=="302"
        #redirection
        counter+=1
        return isIframable(response["location"],counter)
      else
        xFrameOptions = response["x-frame-options"]
        if xFrameOptions and ( xFrameOptions.upcase.include? "DENY" or xFrameOptions.upcase.include? "SAMEORIGIN" )
          return false
        end
      end
    rescue
      return false
    end
    return true
  end
  view :id_atom do |args|
    h = _render_atom
    h[:id] = card.id if card.id
    h    
  end
  view :check_source do |args|
    url = Card::Env.params[:url]
    result = {:result => false }
    if url
      source = Self::Webpage.find_duplicates url
      result[:source] = source.first.left.name if source.any?
    end
    result.to_json
  end
  view :check_iframable do |args|
    url = Card::Env.params[:url]
    if url
      result = {:result => isIframable( url, counter=0 ) }
    else
      result = {:result => false }
    end
    result.to_json
  end
end
