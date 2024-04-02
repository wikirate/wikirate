format do
  def stub_view view
    wrap_with :div,
              class: "card-slot card-slot-stub",
              data: { "stub-url": path(view: view) } do
      ""
    end
  end
end
