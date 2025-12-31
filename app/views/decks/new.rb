# frozen_string_literal: true

module Views
  module Decks
    class New < Views::Base
      attr_accessor :deck

      def initialize(deck:)
        super
        self.deck = deck
      end

      def view_template
        h1 { "Create New Deck" }

        form_with(model: deck) do |form|
          errors = deck.errors
          if errors.any?
            div(class: "error-explanation") do
              h2 { "#{pluralize(errors.count, "problem")} with your deck:" }
              ul do
                errors.full_messages.each do |message|
                  li { message }
                end
              end
            end
          end

          div(class: "field") do
            form.label(:name)
            form.text_field(:name, required: true)
          end

          div(class: "field") do
            form.label(:cards_csv, "Cards (CSV format)")
            form.file_field(:cards_csv, required: true)
          end

          div { form.submit("Create Deck") }
        end
      end
    end
  end
end
