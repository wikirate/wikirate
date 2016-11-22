# -*- encoding : utf-8 -*-

class ProjectUpdates < Card::Migration
  def up
    ensure_card "status", codename: "wikirate_status"
    ensure_card "Organizer", codename: "organizer"

    Card.create! name: "Project+status+*type plus right+*options",
                 type: "Pointer",
                 content: "[[Active]]\n[[Inactive]]"

    Card.search left: { type: "Project" }, right: "status" do |card|
      card.content = card.content =~ /Open/ ? "Active" : "Inactive"
      card.save!
    end

    Card["Project+Open"].update_attributes! name: "Project+Active"
    Card["Project+Closed"].update_attributes! name: "Project+Inactive"

  end
end
