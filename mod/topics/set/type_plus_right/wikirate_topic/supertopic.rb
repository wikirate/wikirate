def virtual?
  new?
end

def wql_content
  { type: :wikirate_topic, right_plus: [:subtopic, { refer_to: name.left }] }
end
