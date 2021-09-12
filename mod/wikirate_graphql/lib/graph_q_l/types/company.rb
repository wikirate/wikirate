module GraphQL
  module Types
    class Company < Card
      field :logo_url, String, null: true,
            description: "url for company logo image"

      field :answers, [Answer], null: false

      def logo_url
        img = object.image_card
        img.format(:text).render_source if img.real?
      end

      def answers
        ::Answer.where(company_id: object.id).limit(10).all
      end
    end
  end
end
