include_set Abstract::ListRefCachedCount,
            type_to_count: :reference,
            list_field: :subject

before :content do
  class_up "card-slot", "_card-link-modal"
end