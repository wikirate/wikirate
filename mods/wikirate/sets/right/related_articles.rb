format :html do
  view :core do |args|
    result = []
    if topics = Card["#{card.left.name}+topics"] and companies = Card["#{card.left.name}+company"]
      companies.item_names.each do |company|
        topics.item_names.each do |topic|
          result << %{
            <a class=\"known-card topic\" href=\"\/#{topic}\">#{topic}</a>
            <a class=\"known-card company\" href=\"\/#{company}\">#{company}</a>
            #{ next_action company, topic}
            }
        end
      end
    end
    result.map{|link| "<div class=\"analysis-link\">#{link}</div>"}.join ' '
  end
  
  def next_action company, topic
    analysis_name = "#{company}+#{topic}"
    if analysis = Card[analysis_name]
      if Card.search(:refer_to => card.left.name, :name=>"#{analysis_name}+article").include? card.left
        process_content "[[#{analysis_name}|Add article]]"
      else
        process_content "[[#{analysis_name}|Needs review]]"
      end
    end
  end
end