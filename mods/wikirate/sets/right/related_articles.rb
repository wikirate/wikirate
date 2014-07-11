format :html do
  
  view :core do |args|
    result = []
    if topics = Card["#{card.left.name}+topics"] and companies = Card["#{card.left.name}+company"]
      companies.item_names.each do |company|
        topics.item_names.each do |topic|
          result << %{
            <a class=\"known-card company\" href=\"\/#{company}\">#{company}</a>
            <a class=\"known-card topic\" href=\"\/#{topic}\">#{topic}</a>
            #{ next_action company, topic}
            }
        end
      end
    end
    result.map{|link| "<div class=\"analysis-link\">#{link}</div>"}.join ' '
  end
  
  def next_action company, topic
    analysis_name = "#{company}+#{topic}"
    article = Card["#{analysis_name}+Article"]
    act = case
      when !article;                                'Start a new Article'
      when !article.includees.include?( card.left); 'Cite this Claim'
      else                                          'Review Article'
      end
    process_content %{ <span class="claim-next-action">[[#{analysis_name} | #{ act }]]</span> }
  end
  
end
