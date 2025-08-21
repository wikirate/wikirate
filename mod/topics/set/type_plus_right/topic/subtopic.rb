include_set Abstract::VirtualSearch,
            cql_content: { type: :topic,
                           right_plus: [:category, { refer_to: "_left" }],
                           limit: 100 }
