#! no set module

class BadgeHierarchy
  extend Abstract::BadgeHierarchy

  hierarchy(
    create: {
      company_register: 1,
      the_company_store: 5,
      inc_slinger: 25
    }
  )
end
