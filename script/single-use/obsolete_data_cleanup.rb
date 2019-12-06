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
   overview
  ].each do |codename|
  next unless Card::Codename[codename]
  delete_code_card codename
end

[
  "Write a new Summary",
  "company overview",
  "topic_overview",
  "featured topic analysis",
  "featured company analysis",
  "Featured Company Overviews",
  "Featured Topic Overviews",
  "How to Participate"
].each do |name|
  delete_card name
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

Card.search(left: { type: :wikirate_topic }, right: :subtopic).each(&:delete!)

Card.where(
  "type_id = #{Card::SourceID} and year(created_at) < 2017 and trash is false " \
  "and not exists (select * from card_references where referee_id = cards.id)"
).find_each do |source_card|
  source_card.include_set_modules
  source_card.delete!
end

Card.connection.execute RELATIONSHIP_VALUE_ACTION_SQL

def import_delete_actions
  Card::Action.where(%{
      action_type = 2
      AND EXISTS (select * from card_actions ca1
                  where comment = 'imported'
                  and ca1.card_id = card_actions.card_id
                  and ca1.id <> card_actions.id)
    })
end

def delete_overwritten_import_actions action_query
  action_query.find_each do |action|
    Card.connection.execute(
      "DELETE from card_actions " \
      "WHERE card_id = #{action.card_id} and id <= #{action.id}"
    )
  end
end

def old_admin_actions
  Card::Action.where(%{
      action_type = 2
      AND EXISTS (select * from card_acts
                  where card_acts.id = card_actions.card_act_id
                  and year(acted_at) < 2018
                  and actor_id in (#{admin_ids * ', ' }))
    })
end

def admin_ids
  ["Vasiliki Gkatziaki", "Richard Mills", "Laureen van Breen"].map do |name|
    Card.fetch_id name
  end
end

delete_overwritten_import_actions import_delete_actions
delete_overwritten_import_actions old_admin_actions

Card.empty_trash

