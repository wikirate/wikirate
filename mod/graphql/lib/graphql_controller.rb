# bypasses card controller, executes graphql queries
class GraphqlController < ActionController::Base
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session

  def execute
    variables = prepare_variables params[:variables]
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      # Query context goes here, for example:
      # current_user: current_user,
    }
    result = GraphQL::CardSchema.execute query,
                                         variables: variables,
                                         context: context,
                                         operation_name: operation_name
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development e
  end

  private

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables variables_param
    case variables_param
    when String
      prepare_string_variable variables_param
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash
      # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def prepare_string_variable string
    return {} unless string.present?

    JSON.parse(string) || {}
  end

  def handle_error_in_development e
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [{ message: e.message, backtrace: e.backtrace }],
                   data: {} }, status: 500
  end
end
