include_set Abstract::Badge

format :html do
  def valued_object
    "record"
  end
end

def badge_type
  :record
end
