# frozen_string_literal: true

RSpec.describe Components::Base do
  it "inherits from Phlex::HTML" do
    expect(described_class.superclass).to eq(Phlex::HTML)
  end

  it "includes Rails helper modules for forms and links" do
    expect(described_class.included_modules).to include(
      Phlex::Rails::Helpers::FormWith,
      Phlex::Rails::Helpers::LinkTo,
      Phlex::Rails::Helpers::ButtonTo
    )
  end

  it "includes Rails helper modules for content" do
    expect(described_class.included_modules).to include(
      Phlex::Rails::Helpers::ImageTag,
      Phlex::Rails::Helpers::MailTo,
      Phlex::Rails::Helpers::Pluralize
    )
  end

  it "includes Rails helper modules for navigation" do
    expect(described_class.included_modules).to include(
      Phlex::Rails::Helpers::Routes,
      Phlex::Rails::Helpers::TurboFrameTag
    )
  end

  it "registers current_user as a value helper" do
    helpers = described_class.instance_variable_get(:@registered_value_helpers)

    expect(helpers).to include(:current_user)
  end
end