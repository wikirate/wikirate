# -*- encoding : utf-8 -*-

class UnpublishedCard < Cardio::Migration
  def up
    ensure_code_card "unpublished"
    ensure_card %i[unpublished right default], type: :toggle
  end
end
