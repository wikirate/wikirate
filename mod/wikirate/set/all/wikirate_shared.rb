format do
  # this is just to add the unknown setting, which was (perhaps unintentionally?)
  # set globally in wikirate before.  removing the setting has some surprising
  # consequences (sigh, undocumented)

  # In principle, we shouldn't do this, though. It means you won't get 404 responses
  # for unknown cards...
  view :core, unknown: true do
    super()
  end
end
