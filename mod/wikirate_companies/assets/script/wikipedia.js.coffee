
decko.slot.ready (slot) ->
  exc = slot.find "._wikipediaExcerpt._unloaded"
  expandExcerpt exc if exc.length > 0



expandExcerpt = (div) ->
  div.removeClass "_unloaded"
  url = div.data "url"
  $.get url + "&origin=*", (json) ->
    div.html excerptFromJson(json)

excerptFromJson = (json) ->
  Object.values(json["query"]["pages"])[0]["extract"]