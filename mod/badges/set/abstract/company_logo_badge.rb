include_set Abstract::CompanyBadge

format :html do
  def valued_object
    "company logo"
  end
end

def badge_action
  :logo
end
