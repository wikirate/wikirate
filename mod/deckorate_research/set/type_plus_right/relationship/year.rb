event :do_not_save_relationship_year, :validate, on: :save do
  abort :success
end
