# note, this has to be here because the view it's overriding is in a non-root module
format :html do
  view :new_buttons, template: :haml
end
