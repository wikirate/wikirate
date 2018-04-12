format do
  view :server_error, perms: :none, error_code: 500 do
    ["Rats!",
     "500 Server Error",
     "Looks like WikiRat's been gnawing on cables. " \
     "Don't let him get away with it.",
     "Ticket the Rat: http://wikirate.org/new/Ticket"
     ].join "\n\n"
  end
end

format :html do
  view :server_error, template: :haml
end