#! no set module

class BadgeHierarchy
  extend Abstract::BadgeHierarchy

  hierarchy(
    create: {
      inside_source: 1,
      a_cite_to_behold: 20,
      a_source_of_inspiration: 50
    }
  )
end
