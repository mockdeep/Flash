# frozen_string_literal: true

module ReadingMap
  # The lines between the nodes on a learner's map, and where each node's
  # lines lead.
  class Lines
    def initialize(user:, nodes:)
      @user = user
      @nodes = nodes
    end

    # Each line between two nodes on the map, with its strength.
    def links
      @links ||=
        begin
          on_map = @nodes.index_by(&:word_list)
          joining = WordListLink.where(word_list: on_map.keys)
            .where(linked_word_list: on_map.keys)

          joining.map { |link| [*ends(link, on_map), link.strength] }
        end
    end

    # The nodes a node's lines lead to, on its ring or further out, each
    # with what studying the node would gain the learner there.
    def leads(node)
      outward = joined_to(node).select { it.ring >= node.ring }

      outward.map { [it, gains[[node.word_list.id, it.word_list.id]]] }
    end

    private

    def joined_to(node)
      links.filter_map do |from, to, _|
        next to if from == node

        from if to == node
      end
    end

    def ends(link, on_map)
      on_map.values_at(link.word_list, link.linked_word_list)
    end

    # Worked out both ways along every line in one query.
    def gains
      @gains ||=
        begin
          pairs = links.flat_map { |from, to, _| [[from, to], [to, from]] }
          Gains.for(@user, pairs.map { |pair| pair.map { it.word_list.id } })
        end
    end
  end
end
