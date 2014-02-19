


CLAIM_SUBJECT_SQL = %{
  select subjects.`key` as subject, claims.id from cards claims 
  join cards as pointers on claims.id   = pointers.left_id
  join card_references   on pointers.id = referer_id
  join cards as subjects on referee_id  = subjects.id
  where claims.type_id =    #{ Card::ClaimID }
  and pointers.right_id in (#{ [ Card::WikirateTopicID, Card['Company'].id ] * ', ' })
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

format :html do

  view :cite do |args|
    @parent.vars[:citation_number] ||= 0
    num = @parent.vars[:citation_number] += 1
    %{<sup><a class="citation" href="##{card.cardname.url_key}">#{num}</a></sup>}
  end


  # navdrop views are called by wikirate-nav js
  view :navdrop, :tags=>:unknown_ok do |args|
    items = Card.search( :type_id=>card.type_id, :sort=>:name, :return=>:name ).map do |item|
      klass = item.to_name.key == card.key ? 'class="current-item"' : ''
      %{<li #{ klass }>#{ link_to_page item }</li>}
    end.join "\n"
    %{ <ul>#{items}</ul> }
  end
    
end



