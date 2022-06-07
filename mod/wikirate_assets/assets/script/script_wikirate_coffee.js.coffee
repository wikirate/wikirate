

$(window).ready ->
  $("body").on "click", "a.card-paging-link", ->
    id = $(this).slot().attr("id")
    #unless history.state?
    #  history.replaceState(slot_id: id, "")
    history.pushState(slot_id: id, url: this.href, "", location.href);
