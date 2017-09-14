decko.slotReady(->
  $('.filter-search-form select,.filter-search-form input').change(->
    $('form').submit()
  )
)
