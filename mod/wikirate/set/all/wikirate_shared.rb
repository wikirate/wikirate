format do
  # this is just to add the unknown setting, which was (perhaps unintentionally?)
  # set globally in wikirate before.  removing the setting has some surprising
  # consequences
  view :core, unknown: true do
    super()
  end
end
