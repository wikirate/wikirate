module Formula
  class Calculator
    class InputItem
      module AllRequired
        def answer_query
          res = super
          return res unless company_list.present?
          # search only for companies that still have a chance to reach a complete set
          # of input values for at least one year.
          res.merge(company_id: company_list.to_a)
        end
      end
    end
  end
end
