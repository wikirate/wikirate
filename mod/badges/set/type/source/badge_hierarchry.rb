#! no set module

class BadgeHierarchy
  extend Abstract::BadgeHierarchy

  add_badge_set :create,
                inside_source: 1,
                a_cite_to_behold: 20,
                a_source_of_inspiration: 50,
                &create_type_count(SourceID)
end
