include_set Abstract::LookupField

def lookup_columns
  %i[value numeric_value imported updated_at editor_id]
end

def answer_id
  left&.id || director.parent.card.id || left_id
  # FIXME: director.parent thing fixes case where metric answer is renamed.
end
