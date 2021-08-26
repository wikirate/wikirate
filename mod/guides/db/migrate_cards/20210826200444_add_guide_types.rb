# -*- encoding : utf-8 -*-

class AddGuideTypes < Cardio::Migration
  def up
    ensure_card "Guide", type: :cardtype, codename: :guide_type
    ensure_card "Reference", type: :cardtype, codename: :reference
    ensure_card "Guide Layout", type: :layout_type, codename: :guide_layout
    ensure_card "Wikirate Layout", type: :layout, codename: :wikirate_layout
  end
end
