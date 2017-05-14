# -*- encoding : utf-8 -*-

class UpdateDoubleCheckFlags < Card::Migration
  def up
    ensure_card "double checked",
                codename: "double_checked"

    ensure_card "double checked+*right+*default",
                type_id: Card::PointerID

    Card::Cache.reset_all

    # update_existing_flags
  end

  def update_existing_flags
    checked_ids = Hash.new { |h, k| h[k] = [] }

    puts "collecting double checks"
    Card.search(right: { codename: "checked_by" },
                return: :id).each do |card_id|
      Card.fetch(card_id).item_names.each do |user|
        checked_ids[user] << "~#{card_id}"
      end
    end

    puts "updating double checks of #{checked_ids.keys.size} users"
    checked_ids.each do |user, ids|
      ensure_card user.to_name.field_name(:double_checked),
                  type_id: Card::PointerID,
                  content: ids.to_pointer_content
    end
  end
end
