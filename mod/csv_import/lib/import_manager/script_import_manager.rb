class ImportError < StandardError
end

# {ImportManager} for scripts. Main difference is you don't have an act card and
# you can choose a error policy. For example throw  an exception on the first error or
# collect all errors and report in the console at the end.
# You can also specify a user who does the imports.
# Unlike the other ImportManagers the ScriptImportManager import doesn't support
# extra data to override fields.
class ScriptImportManager < ImportManager
  def initialize csv_file, conflict_strategy: :skip, error_policy: :fail, user: nil
    super(csv_file, conflict_strategy, {})
    @error_policy = error_policy
    @user = user
  end

  def import_rows row_indices
    with_user do
      super
    end
  end

  def with_user
    if @user
      Card::Auth.with(@user) { yield }
    elsif Card::Auth.signed_in?
      yield
    else
      raise StandardError, "can't import as anonymous"
    end
  end

  def row_failed _csv_row
    case @error_policy
    when :fail then
      raise ImportError, @import_status[:errors].inspect
    when :report then
      puts @import_status[:errors].inspect
    when :skip then
      nil
    end
  end
end
