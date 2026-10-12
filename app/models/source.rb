# frozen_string_literal: true

# Where a word_list's snippets come from: an article, a book, or a drawer of
# scraps. It holds what they share, and each snippet is one of its sections.
class Source < ApplicationRecord
  LICENSES = {
    "all_rights_reserved" => { name: "All rights reserved" },
    "public_domain" => { name: "Public domain", shareable: true },
    "cc_by_sa" => {
      name: "CC BY-SA 4.0",
      url: "https://creativecommons.org/licenses/by-sa/4.0/",
      shareable: true,
    },
  }.freeze

  belongs_to :word_list
  has_many :snippets, dependent: :destroy

  validates :word_list, :title, presence: true
  validates :word_list_id, uniqueness: true
  validates :license, inclusion: { in: LICENSES.keys }
  validates :source_url,
            format: { with: %r{\Ahttps?://\S+\z}, allow_blank: true }
end
