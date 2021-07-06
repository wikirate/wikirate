
def track_page_from_server?
  tracker && response_format.in?(%i[csv json]) && !internal_api_request?
end

def tracker_options
  # cg = content grouping
  # cd = custom dimension
  super.merge cg1: type_name,
              cg2: (export_request? ? "Export" : "API"),
              cd1: profile_type
end

def export_request?
  request_var("HTTP_SEC_FETCH_MODE") == "navigate" || response_format == :csv
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
