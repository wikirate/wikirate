
def track_page_from_server?
  response_format.in?(%i[csv json]) && !internal_api_request?
end

def tracker_options
  super.merge cg1: type_name, cg2: (export_request? ? "Export" : "API")
end

def export_request?
  request_var("HTTP_SEC_FETCH_MODE") == "navigate" || response_format == :csv
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
    super.merge contentGroup1: card.type_name, contentGroup2: "Web"
  end
end
