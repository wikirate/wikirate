# "+report search" cards are virtual cards used to manage searches for
# contribution reports

# In the context of a User Profile page, these reports take the form of
#   [User]+[Cardtype]+report search

# In the context of a Research Group page, the reports take the form of
#   [User]+[Cardtype]+[Project]+report search

# In both cases, the report queries can only vary structurally by cardtype
# (not by user or project), so the query methods are defined on the cardtype
# set modules (eg self/metric).

attr_accessor :variant

def user_plus_cardtype_name
  @user_plus_cardtype_name ||=
    project? ? cardname.left_name.left_name : cardname.left_name
end

def user_card
  @user_card ||= Card.fetch user_plus_cardtype_name.left
end

def cardtype_card
  @cardtype_card ||= Card.fetch user_plus_cardtype_name.right
end

def project?
  @project.nil? ? (@project = cardname.parts.size > 3) : @project
end

def project_name
  cardname.right_name
end

def project_card
  @project_card ||= Card.fetch project_name if project?
end

def raw_ruby_query _overide={}
  project? ? project_report_query : standard_report_query
end

def standard_report_query
  cardtype_card.send "#{variant}_report_query", user_card.id
end

def project_report_query
  method = "#{variant}_project_report_query"
  cardtype_card.send method, user_card.id, project_card.id
end

format :html do
  # uses structure to hold variant
  # (so that it can be passed around via slot options)
  view :core do
    card.variant = voo.structure if voo.structure
    super()
  end
end
