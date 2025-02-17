include_set Abstract::CodeContent
include_set Abstract::VirtualSet

format do
  view :raw, unknown: true do
    <<~MESSAGE
      Welcome to Wikirate!

      Dear {{_|name}},

      You are now officially a member of the global Wikirate community.
      We collaboratively collect, analyze and share open data on company
      commitments, actions and impacts on people and the planet.

      To help you get started, here are some useful links:

      - Account and settings
         [https://wikirate.org/Manage_Your_Account#edit_your_public_profile]:
          Upload a profile picture and edit your account.

      - Topics [https://wikirate.org/topics],
        Companies [http://wikirate.org/companies],
        Metrics [https://wikirate.org/metrics], and
        Datasets: [https://wikirate.org/datasets]:
          Browse the data through different lenses.

      - Projects [https://wikirate.org/Project]:
          Find your way into the data research.

      - Guides [https://wikirate.org/guides]:
          Do deep dives on key features.

      - FAQs [https://wikirate.org/Frequently_Asked_Questions]:
          Find answers to most of your questions.

      If you get stuck or have any questions, send us a note at info@wikirate.org.

      We can’t wait to hear from you,
      - The Wikirate Team

    MESSAGE
  end
end
