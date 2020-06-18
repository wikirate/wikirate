#! no set module

# all badges related to sources
class BadgeSquad
  if defined? Card::SourceID
    extend Abstract::BadgeSquad

    add_badge_line :create,
                   inside_source: 1,
                   a_cite_to_behold: 20,
                   a_source_of_inspiration: 50,
                   &create_type_count(Card::SourceID)
  end
end
