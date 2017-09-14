# -*- encoding : utf-8 -*-

class ProjectUpdates < Card::Migration
  def up
    merge_cards [
      "Project+*self+*structure",
      "Project+status+*type plus right+*options",
      "Company+topic+*type_plus_right+*structure",
      "Organizer",
      "description",
      "status"
    ]

    Card::Codename.reset_cache

    Card.search left: { type: "Project" }, right: "status" do |card|
      card.content = card.content =~ /Open/ ? "Active" : "Inactive"
      card.save!
    end

    create_or_update "Project+Open", name: "Project+Active"
    create_or_update "Project+Closed", name: "Project+Inactive"
  end
end
