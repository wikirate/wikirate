def with_success_params
  init_success_params
  yield
  clear_success_params
end

def success_params
  []
end

def init_success_params
  success_params.each { |key| success.params[key] = [] }
end

def clear_success_params
  success_params.each do |key|
    success.params.delete(key) unless success[key].present?
  end
end

format :html do
  view :import_success do
    wrap_with :div, id: "source-preview-iframe",
                    class: "webpage-preview non-previewable" do
      wrap_with :div, class: "redirect-notice" do
        _render_content structure: "source item preview"
      end
    end
  end

  def success_params
    card.singleton_class::SUCCESS_MESSAGES
  end

  def success_messages
    success_params.each_with_object([]) do |(key, headline), a|
       values = Env.params[key]
       next unless values.present?
       a << render_success_message(headline, values)
     end.join
  end

  def render_success_message headline, messages
    items = messages.map { |index, msg| "Row #{index}: #{msg}" }
    alert("warning") do
      with_header headline, list_tag(items), level: 4
    end
  end
end
