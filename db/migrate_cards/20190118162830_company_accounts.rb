# -*- encoding : utf-8 -*-

class CompanyAccounts < Card::Migration
  def up
    ensure_card %i[wikirate_company type accountable], content: "1"
    create_account_card
    only_wikirate_team_can :create
    only_wikirate_team_can :update
  end

  def only_wikirate_team_can action
    ensure_card [:wikirate_company, :account, :type_plus_right, action],
                content: "WikiRate Team"
  end

  # this is a hack to avoid the +*account creation validations.
  # frankly dodgy that this works.
  def create_account_card
    tmp = Card.create! name: "Company+scratch"
    tmp.update! name: "Company+*account"
  end
end
