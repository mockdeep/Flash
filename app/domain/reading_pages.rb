# frozen_string_literal: true

# A text cut into pages for the Read tab, the way a book is: each snippet
# starts a page, and a page breaks before the word that would take it past
# its length, mid-paragraph or mid-sentence if need be. Length is counted in
# Han characters in a language written without spaces, and in words in one
# written with them. Pages are worked out when shown, so none is stored; a
# page is found by any token on it.
class ReadingPages
  include Enumerable

  CHARACTERS = 300
  WORDS = 150
  # Opening quotes and brackets go to the page of the word they open.
  OPENING = /[\p{Ps}\p{Pi}]+\z/

  Start = Data.define(:sentence_id, :index)
  Line =
    Data.define(:tag, :pieces) do
      def tokens = pieces.map(&:token)
    end
  Page =
    Data.define(:number, :lines) do
      def first? = number == 1

      def start
        piece = placed.first
        Start.new(sentence_id: piece.sentence_id, index: piece.index)
      end

      # Its pieces that belong to a sentence, by which the page is found.
      def placed = lines.flat_map(&:pieces).select(&:sentence_id)

      def tokens = lines.flat_map(&:tokens)
    end

  # A deck with no source has no text, nor a language to count it in.
  def self.for(deck)
    new(snippets: deck.readable_snippets, language: deck.source&.language)
  end

  def initialize(snippets:, language:)
    @language = language
    @pages = []
    @numbers = {}
    snippets.each { paginate(it) }
  end

  def each(&) = @pages.each(&)

  delegate :size, to: :@pages

  # The page holding the token, or the first page.
  def at(sentence_id, index)
    key = [sentence_id, index].map { Integer(it.to_s, 10, exception: false) }
    page(@numbers.fetch(key, 1))
  end

  def page(number)
    @pages[number - 1] if number.positive?
  end

  private

  def paginate(snippet)
    @lines = []
    @length = 0
    lines_of(snippet).each do |tag, pieces|
      @lines << Line.new(tag:, pieces: [])
      pieces.each { add(it) }
    end
    close
  end

  def lines_of(snippet)
    heading = snippet.heading_paragraph
    lines = snippet.paragraphs.map { [:p, it.pieces] }
    heading.text.present? ? [[:h3, heading.pieces], *lines] : lines
  end

  def add(piece)
    length = length_of(piece.text)
    turn if length.positive? && @length.positive? && @length + length > limit
    @length += length
    @lines.last.pieces << piece
  end

  def turn
    line = @lines.last
    carried = carry_opening(line.pieces)
    close
    @lines = [Line.new(tag: line.tag, pieces: carried)]
    @length = 0
  end

  # Takes the opening quotes and brackets off the end of a line. What the
  # text has between tokens may hold more, such as the full stop before a
  # quote, which stays behind.
  def carry_opening(pieces)
    carried = []
    while (piece = pieces.last) && (opening = opening_of(piece))
      pieces.pop
      carried.unshift(split_off(piece, opening, pieces))
    end
    carried
  end

  def split_off(piece, opening, pieces)
    return piece if opening == piece.text

    pieces << Snippet::Piece.gap(piece.text.delete_suffix(opening))
    Snippet::Piece.gap(opening)
  end

  # A token is carried whole or not at all.
  def opening_of(piece)
    opening = piece.text[OPENING]
    opening if opening == piece.text || (opening && piece.sentence_id.nil?)
  end

  def close
    lines = @lines.reject { it.pieces.empty? }
    page = Page.new(number: @pages.size + 1, lines:)
    return if page.placed.empty?

    @pages << page
    page.placed.each { @numbers[[it.sentence_id, it.index]] = page.number }
  end

  def length_of(text)
    if @language.spaces
      text.split.count { @language.word?(it) }
    else
      @language.word_chars(text).size
    end
  end

  def limit = @language.spaces ? WORDS : CHARACTERS
end
