# -*- encoding : utf-8 -*-

class CheckRequestedBy < Card::Migration
  def up
    ensure_card "requested double checks", codename: "requested_double_checks",
                type_id: Card::SearchTypeID
  end
end
