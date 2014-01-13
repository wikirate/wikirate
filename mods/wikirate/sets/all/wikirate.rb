


CLAIM_SUBJECT_SQL = %{
  select subjects.`key` as subject, claims.id from cards claims 
  join cards as pointers on claims.id=pointers.left_id
  join card_references on pointers.id = referer_id
  join cards as subjects on referee_id = subjects.id
  where claims.type_id = #{Card::ClaimID}
  and pointers.right_id in (#{ [ Card::WikirateTopicID, Card['Company'].id ] * ', ' })
  and claims.trash is false
  and pointers.trash is false    
  and subjects.trash is false; 
}

module ClassMethods

=begin  
  def topic_children
    @@topic_children ||= begin
      Account.as_bot do
        hash = {}
        Card.search( :left=>{:type=>'Topic'}, :right=>'subtopic', :limit=>0, :sort=>:name ).each do |junc|
          parent = junc.cardname.trunk_name.key
          children = junc.item_names.map { |n| n.to_name.key }
          hash[parent] = children        
        end
        hash
      end
    end
  end
  
  def root_topics
    @@root_topics ||= begin
      all_topics_that_are_children = [ topic_children.values ].flatten.uniq
      array = []
      topic_children.each do |parent, children|
        if !all_topics_that_are_children.member? parent
          array << parent
        end
      end
      array
    end
  end
  
  def all_topics
    @@all_topics ||= [ topic_children.keys, topic_children.values ].flatten  
  end
  
  def leaf_topics
    @@leaf_topics ||= begin
      all_topics.flatten.find_all do |topic|
        !topic_children[topic]
      end
    end
  end
  
  def topic_descendants topic
    list = [ topic ]
    if children = topic_children[ topic ]
      children.each do |child|
        list += topic_descendants( child )
      end
    end
    list
  end
  
  def topic_parent topic
    topic_children.each do |parent, children|
      return parent if children.member? topic
    end
    nil
  end
=end
  
  def claim_counts subj
    @@claim_counts ||= {}
    @@claim_counts[ subj ] ||= begin
      subjname = subj.to_name
      if subjname.simple?
#        if all_topics.member? subj
#          subj = topic_descendants subj
#        end
        claim_subjects.find_all do |id, subjects|
          subjects_apply? subjects, subj
        end
      else
#        return 'oopo'
        left = subjname.left
#        right = topic_descendants subjname.right
        claim_subjects.find_all do |id, subjects|
          subjects_apply? subjects, left  and subjects_apply? subjects, right
        end
      end.size
    end
  end
  
  
  
  def subjects_apply? references, test_list
    !!Array.wrap(test_list).find do |subject|
      references.member? subject
    end
    
  end
  
  def claim_subjects
    @@claim_subjects ||= begin
      hash = {}
      sql = 
      ActiveRecord::Base.connection.select_all( CLAIM_SUBJECT_SQL ).each do |row|
        hash[ row['id'] ] ||= []
        hash[ row['id'] ] << row['subject']
      end
      hash
    end
  end

  def reset_claim_counts
    @@claim_counts = nil
    @@claim_subjects = nil
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
    

  # TOPIC TREE 
  # this is different from (and pre-dates) the jstree-based topic editor.
  # it's the old Topics tree on the main Topics page
  # merits revisiting (and unification?)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  view :closed_branch do |args|
    wrap :closed_branch do
      basic_branch :closed, show_arrow = branch_has_kids?
    end
  end

  view :open_branch do |args|
    @default_search_params = { :limit=> 1000 }
    subtopics_card = Card.fetch "#{card.cardname.trunk_name}+children+branch"#{}"+unlimited"
    wrap :open_branch do
      basic_branch(:open) + 
      subformat( subtopics_card )._render_content( :item => :closed_branch )
    end
  end


  def basic_branch state, show_arrow=true
    branch_name = card.cardname.trunk
    arrow_link = case
      when state==:open
        link_to_view '', :closed_branch, :title=>"close #{branch_name}", :class=>"ui-icon ui-icon-circle-triangle-s toggler slotter"
      when show_arrow
        link_to_view '', :open_branch, :title=>"open #{branch_name}", :class=>"ui-icon ui-icon-circle-triangle-e toggler slotter"
      else
        %{ <a href="javascript:void()" class="title branch-placeholder"></a> }
      end

    %{ 
      <div class="closed-view">
        <h1 class="card-header">
          #{ arrow_link }
          #{ link_to_page branch_name, nil, :class=>"branch-direct-link", :title=>"go to #{branch_name}" }
        </h1> 
        #{ 
          wrap_body :body_class=>'closed-content', :content=>true do
            render_closed_content
          end          
        }
      </div>
    }
  end

  def branch_has_kids?
    branch_card = card.trunk
    case field = tree_children_field(branch_card.type_name)
    when nil      ; false
    when 'always' ; true
    else Card.exists? "#{branch_card.name}+#{field}"
    end
  end

  # not great naming.  Idea is to be able to see at a glance whether a card has children.
  # if represented as a pointer from the card (eg <topic>+subtopics), then "subtopics" is the val we're going for.
  # otherwise it gets more complex...
  def tree_children_field type_name
    @@tree_children_field ||= {}
    if @@tree_children_field.has_key? type_name
      @@tree_children_field[type_name]
    else
      @@tree_children_field[type_name] = begin
        field = Card.fetch("#{type_name}+*tree children field") and
          field.item_names.first
      end
    end
  end

end



