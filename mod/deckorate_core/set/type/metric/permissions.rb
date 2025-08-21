def researchable?
  researched? || hybrid?
end

def designer?
  Auth.as_id == metric_designer_id
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

private

def steward_id_lists
  super << metric_designer_id
end
