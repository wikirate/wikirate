# -*- encoding : utf-8 -*-

class RemoveMoreCachedCounts < Card::Migration
  disable_ddl_transaction!

  def up
    [{ right: { codename: "contribution_count" } },
     { right: { codename: "direct_contribution_count" } }].each do |wql|
      Card.search(wql).each do |card|
        card.delete
      end
    end
    Card.search(left: { right: { type_id: Card::WikirateCompanyID } },
                right: { codename: "cached_count" }).each do |card|
      card.delete
    end

    Card::Cache.reset_all
    Card.empty_trash
  end
end
