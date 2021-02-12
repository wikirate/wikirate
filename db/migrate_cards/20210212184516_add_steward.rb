# -*- encoding : utf-8 -*-

class AddSteward < Cardio::Migration
  def up
    ensure_code_card "Steward"
    ensure_card %i[metric steward type_plus_right default], type_code: :pointer
    ensure_card %i[steward right content_options],
                type_code: :search_type, content: "{ \"right_plus\": \":account\" }"

  end
end
