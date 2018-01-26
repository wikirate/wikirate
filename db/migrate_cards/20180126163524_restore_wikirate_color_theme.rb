# -*- encoding : utf-8 -*-

class RestoreWikirateColorTheme < Card::Migration
  def up
    data_path = File.expand_path("../data/wikirate_theme/colors.scss", __FILE__)
    ensure_card "customizable bootstrap skin+custom theme+colors",
                content: File.read(data_path)
  end
end
