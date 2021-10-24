# -*- encoding : utf-8 -*-

class ReorderAllScript < Cardio::Migration
  def up
    mods = %w[
      script ace_editor bootstrap date rules tinymce_editor prosemirror_editor
      wikirate_layout wikirate_assets sources metrics research homepage
    ]
    Card[:all, :script].update!(
      content: mods.map { |m| "mod: #{m}+*script" }.to_pointer_content
    )
  end
end
