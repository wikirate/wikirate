# -*- encoding : utf-8 -*-

class FixCheckRequests < Card::Migration
  def up
    Card.search(right: "checked by").each do |card|
      next unless card.content == "[[request]]"
      card.update_attributes! content: "[[request]]\n[[#{card.updater.name}]]"
    end
  end
end
