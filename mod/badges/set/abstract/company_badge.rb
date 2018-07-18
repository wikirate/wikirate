include_set Abstract::Badge

format :html do
  def valued_action
    "adding"
  end

  def valued_object
    "company"
  end
end

def badge_action
  :create
end

def badge_type
  :wikirate_company
end
