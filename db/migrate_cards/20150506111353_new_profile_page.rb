# -*- encoding : utf-8 -*-

class NewProfilePage < Card::Migration
  def up
    Card.create! name: "activity", codename: "activity"
    Card.create! name: "showcase", codename: "showcase"
    Card.fetch("my_contributions").update_attributes! codename: "my_contributions"
    Card.fetch("campaign").update_attributes! codename: "campaign"
    import_json "new_profile_page.json"
  end
end
