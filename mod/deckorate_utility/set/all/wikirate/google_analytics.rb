
def track_page!
  hit = ::Staccato::Pageview.new tracker, tracker_options
  hit.add_custom_dimension 1, profile_type
  # the following is a bit of hack, because staccato doesn't yet support content groups
  hit.custom_dimensions.merge! tracker_content_groups
  hit.track!
end

def track_page_from_server?
  tracker && response_format.in?(%i[csv json]) && !internal_api_request?
end

def tracker_content_groups
  { cg1: type_name, cg2: format_content_group }
end

def format_content_group
  response_format == :csv ? "CSV" : "JSON"
  # request_var("HTTP_SEC_FETCH_MODE") == "navigate" ||
end

def profile_type
  Auth.current&.profile_type_card&.first_name
end

def response_format
  Env.controller&.response_format
end

def request_var variable
  Env.controller.request.env[variable]
end

def internal_api_request?
  Env.ajax? && request_var("HTTP_SEC_FETCH_SITE") == "same-origin"
end

format :html do
  def google_analytics_snippet_vars
    super.merge contentGroup1: card.type_name,
                contentGroup2: "Web",
                dimension1: card.profile_type
  end
end
