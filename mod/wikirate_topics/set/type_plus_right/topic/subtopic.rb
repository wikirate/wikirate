def virtual?
  new?
end

def cql_content
  { type: :topic, right_plus: [:category, { refer_to: name.left }] }
end
