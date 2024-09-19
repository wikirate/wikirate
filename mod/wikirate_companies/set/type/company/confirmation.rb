event :require_confirmation, :validate, on: :create, when: :require_confirmation? do
  raise Card::Error::ConfirmationRequired
end

def require_confirmation?
  Card::Auth.api_act? && !Env.params[:confirmed]
end

format do
  view :confirmation_required, unknown: true do
    confirmation_message
  end

  def confirmation_message
    "Before adding a new company, please confirm that there are no duplicates. " \
    "You can then proceed using the confirmed=true flag."
  end

  def potential_duplicates
    Env.with_params filter: { name: card.name } do
      :company.card.format.os_search_returning_cards
    end
  end
end

format :json do
  view :confirmation_required do
    {
      message: confirmation_message,
      potential_duplicates: listing(potential_duplicates, view: :atom)
    }
  end
end

format :html do
  view :confirmation_required, template: :haml
end
