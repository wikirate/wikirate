include_set Abstract::Badge

format :html do
  def valued_object
    "answer"
  end
end

def badge_type
  :metric_answer
end
