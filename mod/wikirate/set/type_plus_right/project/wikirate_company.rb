def project_name
  cardname.left
end

def company_project_card company_card
  Card.fetch company_card.name, project_name, new: {}
end

format :html do
  view :core do
    wrap_with :div, class: "progress-bar-table" do
      card.item_cards.map do |company|
        next unless company.type_id == WikirateCompanyID
        nest card.company_project_card(company), view: :progress_bar_row
      end
    end
  end
end
