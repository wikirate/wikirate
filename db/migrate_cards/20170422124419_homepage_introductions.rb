# -*- encoding : utf-8 -*-

class HomepageIntroductions < Card::Migration
  def up
    ensure_card "homepage: introductions", codename: "homepage_introductions"
  end
end
