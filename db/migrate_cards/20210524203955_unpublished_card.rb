# -*- encoding : utf-8 -*-

class UnpublishedCard < Cardio::Migration
  def up
    ensure_code_card "unpublished"
  end
end
