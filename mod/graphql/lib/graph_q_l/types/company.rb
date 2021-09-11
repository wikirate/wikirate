module GraphQL
  module Types
    class Company < Card
      field :logo_url, String, null: true,
            description: "url for company logo image"

      def logo_url
        img = object.image_card
        img.format(:text).render_source if img.real?
      end
    end
  end
end
