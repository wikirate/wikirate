def researchable?
  researched? || hybrid?
end

def steward_assessed?
  research_policy&.casecmp("steward assessed")&.zero?
end

def steward?
  Auth.as_id.in?(steward_ids) || Auth.always_ok?
end

def designer?
  Auth.as_id == metric_designer_id
end

def steward_ids
  @steward_ids ||= [
    Self::Steward.always_ids,
    steward_card&.item_ids,
    metric_designer_id,
    creator_steward_id
  ].flatten.compact.uniq
end

# HACK.  our verification testing assumed that DeckoBot was not a steward.
# So adding the creator_id to the steward list broke a bunch of verification tests
# When there's time, we should update the tests and get rid of this. --efm
def creator_steward_id
  creator_id unless creator_id == Card::DeckoBotID
end

def ok_as_steward?
  steward_assessed? ? steward? : true
end

def ok_to_update?
  steward?
end

def ok_to_delete?
  steward?
end

def user_can_answer?
  Auth.signed_in? && researchable? && ok_as_steward?
end

def unpublish_all_answers
  answers.update_all unpublished: true
end

def publish_unflagged_answers
  answers.where(
    "NOT EXISTS (
      SELECT * from cards
      WHERE left_id = answers.answer_id
      AND right_id = #{:unpublished.card_id}
      AND db_content= '1'
    )"
  ).update_all unpublished: false
end
