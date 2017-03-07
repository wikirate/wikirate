#! no set module

class BadgeHierarchy
  extend Abstract::BadgeHierarchy

  hierarchy(
    create: {
      company_register: 1,
      the_company_store: 5,
      inc_slinger: 25
    },
    logo: {
      logo_brick: 1,
      how_lo_can_you_go: 10,
      logo_and_behold: 100
    }
  )
end
