
def api_tracker_event_params
  super.merge(
    profile_type: profile_type.to_s,
    user_type: user_type
  )
end

def profile_type
  Auth.current&.profile_type_card&.first_name
end

def user_type
  if Auth.always_ok?
    "admin"
  elsif Self::WikirateTeam.member?
    "team"
  elsif Auth.signed_in?
    "registered"
  else
    "anonymous"
  end
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
