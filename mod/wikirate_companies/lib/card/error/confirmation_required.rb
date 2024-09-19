class Card
  class Error
    # special error class for confirmation requirement
    # (not an error response, but otherwise follows the error pattern)
    class ConfirmationRequired < UserError
      self.status_code = 200
      self.view = :confirmation_required
    end
  end
end
