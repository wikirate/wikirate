include_set Abstract::SocialMedia
include_set Abstract::CodeContent

format :html do
  view :core, template: :haml, cache: :deep
end
