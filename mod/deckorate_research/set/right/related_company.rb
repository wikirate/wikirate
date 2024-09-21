event :do_not_save_related_company, :validate, on: :save do
  abort :success
end

format :html do
  view :input do
    select_tag :content,
               class: "form-control",
               data: { "options-card": :company.cardname },
               placeholder: rate_subject
  end
end
