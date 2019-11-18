require File.expand_path "../../../config/environment", __FILE__

include Card::Model::SaveHelper

def delete_cards_of_type type_id
  return unless type_id

  Card.search(type_id: type_id, limit: 0).each(&:delete!)
end

Card::Auth.as_bot

# remove old types (without codenames)
["Old Project", "Task", "Publication"].each do |type_name|
  delete_cards_of_type Card.fetch_id(type_name)
  delete_card type_name
end

# remove old types (with codenames)
%i[claim wikirate_analysis].each do |codename|
  next unless (type_id = Card::Codename.id codename)
  delete_cards_of_type type_id
  delete_code_card codename
end

# get rid of vote count histories
%i[vote_count upvote_count downvote_count].each do |count_code|
  next unless (count_id = Card::Codename.id count_code)
  cond = "card_id in (select id from cards where right_id = #{count_id})"
  Card::Action.where(cond).delete_all
end

# delete code cards no longer in use.
%i[
   add_value
   analyses_with_articles
   analysis_contributions
   cached_content
   category_details
   changed_card
   citation_count
   cited_claims
   claim_perspective
   contributed_analysis
   contributed_campaigns
   contributed_claims
   contributed_metrics
   contributed_sources
   direct_contribution_count
   make_a_claim
   monetary_details
   numeric_details
   quick_claim
   quick_page
   the_count
   wikirate_claim_count
   yinyang_drag_item
  ].each do |codename|
  next unless Card::Codename[codename]
  delete_code_card codename
end

# get rid of histories of relationship/inverse relationship value cards
# (they're just counts)
RELATIONSHIP_VALUE_ACTION_SQL = %{
  DELETE from card_actions
  WHERE EXISTS (
     SELECT * from cards c
     JOIN answers a on c.left_id = a.answer_id
     WHERE card_actions.card_id = c.id
     AND c.right_id = #{Card::ValueID}
     AND metric_type_id in (#{Card::RelationshipID}, #{Card::InverseRelationshipID})
  )
}
Card.connection.execute RELATIONSHIP_VALUE_ACTION_SQL

Card.empty_trash
