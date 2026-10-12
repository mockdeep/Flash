# frozen_string_literal: true

RSpec.describe Components::SourceLicense, type: :view do
  def render_for(source)
    Capybara.string(view.render(described_class.new(source:)))
  end

  it "links a license to its terms" do
    page = render_for(build(:source, license: "cc_by_sa"))
    url = "https://creativecommons.org/licenses/by-sa/4.0/"

    expect(page).to have_link("CC BY-SA 4.0", href: url)
  end

  it "names a license without terms to link" do
    page = render_for(build(:source, license: "public_domain"))

    expect(page).to have_text("Public domain")
  end
end
