include_set Abstract::MetricChild, generation: 1
include_set Abstract::LookupField
include_set Abstract::DesignerPermissions
include_set Abstract::PublishableField

event :toggle_answer_publication, :finalize, changed: :content do
  if action == :delete || content == "1"
    unpublish_all_answers
  else
    published_unflagged_answers
  end
end

def answers
  Answer.where metric_id: left_id
end

def unpublish_all_answers
  answers.update_all unpublished: true
end

def published_unflagged_answers
  answers.where(
    %Q[NOT EXISTS (
      SELECT * from cards
      WHERE left_id = answers.answer_id
      AND right_id = #{:unpublished.card_id}
      AND db_content= '1'
    )]
  ).update_all unpublished: false
end
