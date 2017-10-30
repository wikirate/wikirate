

# this is pretending as a pointer card
def item_names _args
  initiative_name = name.left
  # find all participant and add to the pointer card
  editors = Card.search editor_of: { left: initiative_name }, return: "name"
  editors += Card.search(
    editor_of: { left: { found_by: "#{initiative_name}+project" } },
    return: "name"
  )
  editors += Card.search(
    editor_of: { right_plus:
      [
        "Project",
        {
          refer_to: { found_by: "#{initiative_name}+Project" }
        }
      ] }, return: "name"
  )
  editors.delete(Card[WagnBotID].name)
  editors.uniq
end
