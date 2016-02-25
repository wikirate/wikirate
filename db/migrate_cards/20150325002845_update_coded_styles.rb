# -*- encoding : utf-8 -*-

class UpdateCodedStyles < Card::Migration
  def up

    #stylesheets
    Card['style: bootstrap cards'].update_attributes! :codename=>'bootstrap_cards'
    Card['style: bootstrap compatible'].update_attributes! :codename=>'style_bootstrap_compatible'
    Card['style: bootstrap theme'].update_attributes!(
      :name=>'theme: bootstrap default',
      :codename=>'theme_bootstrap_default'
    )

    #skins
    Card['simple skin'].update_attributes!(
      :content=>"[[style: jquery-ui-smoothness]]\n[[style: cards]]\n[[style: right sidebar]]\n[[style: common]]\n[[style: traditional]]\n[[style: glyphicons]]\n[[style: bootstrap compatible]]"
    )
    # Card['raw bootstrap skin'].update_attributes!(
    #   :name=>'themeless bootstrap skin',
    #   :content=> "[[style: bootstrap]]\n[[style: jquery-ui-smoothness]]\n[[style: cards]]\n[[style: right sidebar]]\n[[style: bootstrap cards]]"
    # )
    #
    # bootstrap_default = Card['simple bootstrap skin']
    # bootstrap_default.name = 'bootstrap default skin'
    # bootstrap_default.content = "[[themeless bootstrap skin]]\n[[theme: bootstrap default]]"
    # bootstrap_default.update_referers = true
    # bootstrap_default.save!


    # merge "style: functional" and "style: standard" into "style: cards"
    old_func = Card[:style_functional]
    old_func.name = 'style: cards'
    old_func.codename = 'style_cards'
    old_func.save!

    old_stand = Card[:style_standard]
    old_stand.codename = nil
    old_stand.delete!
  end
end
