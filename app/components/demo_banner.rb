# frozen_string_literal: true

module Components
  class DemoBanner < Components::Base
    def view_template
      div(class: "demo-banner") do
        p(class: "demo-banner__text") do
          plain("You're trying a demo. ")
          link_to("Sign up free", new_account_path, class: "demo-banner__link")
          plain(" to save your progress.")
        end
      end
    end
  end
end
