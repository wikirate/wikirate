format do
  view :conversion_error, perms: :none do
    "PDF conversion failed"
  end
end

format :html do
  view :preview do
    wrap_with :div, class: "nodblclick" do
      nest card.file_card, view: :preview
    end
  end

  view :conversion_error do
    voo.title = "Unable to create Citable Source File"
    class_up "d0-card-header", "bg-danger text-white"
    frame { haml :conversion_error }
  end

  # when successfully adding in a sourcebox context, refresh the whole source tab
  def new_success
    research_dashboard? ? { view: :research_success } : super
  end

  def research_dashboard?
    params["_Company"]
  end

  view :research_success, wrap: :slot, template: :haml

end
