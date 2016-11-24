# def project_name
#   cardname.left
# end
#
# def company_project_card company_card
#   Card.fetch company_card.name, project_name, new: {}
# end
#
# format :html do
#   view :core do
#     wrap_with :div, class: "progress-bar-table" do
#       card.item_cards.map do |company|
#         next unless company.type_id == WikirateCompanyID
#         nest card.company_project_card(company), view: :progress_bar_row
#       end
#     end
#   end
# end

include_set Abstract::Table

def project_name
  cardname.left
end

def company_project_card company_card
  Card.fetch company_card.name, project_name, new: {}
end

format :html do
  view :core do
    wrap_with :div, class: "progress-bar-table" do
      wikirate_table :company,
                     ["Company", "Metrics Researched", "Research Company"],
                     all_company_project_cards,
                     [:company_thumbnail, :research_progress_bar, :research_button],
                     opts: [class: "company-research"]
    end
  end

  def all_company_project_cards
    card.item_cards.map do |company|
      next unless company.type_id == WikirateCompanyID
      card.company_project_card(company)
    end.compact
  end
end
