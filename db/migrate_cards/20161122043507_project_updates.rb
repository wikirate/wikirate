# -*- encoding : utf-8 -*-

class ProjectUpdates < Card::Migration
  def up
    merge_cards [
      "Project+*self+*structure",
      "Project+status+*type plus right+*options", "status",
      "Organizer",
      "description",
      "status"
    ]

    Card::Codename.reset_cache

    Card.search left: { type: "Project" }, right: "status" do |card|
      card.content = card.content =~ /Open/ ? "Active" : "Inactive"
      card.save!
    end

    Card["Project+Open"].update_attributes! name: "Project+Active"
    Card["Project+Closed"].update_attributes! name: "Project+Inactive"
  end
end
