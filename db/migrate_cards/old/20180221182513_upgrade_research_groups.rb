# -*- encoding : utf-8 -*-

class UpgradeResearchGroups < Card::Migration
  def up
    merge_cards %w[researcher+*right+*default
                   conversation+*type+*structure
                   conversation+*right+*structure
                   nav_bar_menu]

    # changes conversation cards from having +project fields to having +tag fields
    # (generalizing them)
    Card.fetch("Conversation+Project+*type_plus_right")
        .item_cards(limit: 0)
        .each do |project_tag|
      project_tag.update! name: project_tag.name.swap_part("Project", "Tag")
    end
    Card["Project+conversation+*type_plus_right+*structure"]&.delete!
  end
end
