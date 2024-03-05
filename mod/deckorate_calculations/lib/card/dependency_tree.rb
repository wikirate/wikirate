class Card
  # Build a tree of metrics that depend on a given metric (when dependency
  # type is :depender) or that a metric depends on (when dependency type is :dependee)
  class DependencyTree
    attr_reader :tree, :nodes

    Node = Struct.new :metric, :children, :ancestors

    # @param root_metrics [Array] list of first level dependencies
    # @param dependency_type [Symbol] either :depender or :dependee
    def initialize dependency_type, metric
      @dependency_type = dependency_type
      @tree = Node.new metric, [], []
      @nodes = []
      add_children @tree
    end

    def each_metric &block
      metrics.each(&block)
    end

    def metrics
      @metrics ||= @nodes.sort_by! { |n| n.ancestors.size }.map(&:metric)
    end

    private

    # each node has
    # - metric
    # - children (for depender trees: children nodes are direct dependers;
    #             for dependee trees, children nodes are direct dependees)
    # - ancestors (for depender trees, ancestors are dependee metric ids within the tree.
    #              for dependee trees, ancestors are depender metric ids within the tree)

    def node metric
      @nodes.find { |n| n.metric == metric }
    end

    def add_children node
      children_for_metric(node.metric).each { |metric| add_child node, metric }
    end

    def children_for_metric metric
      metric.send "direct_#{@dependency_type}_metrics"
    end

    def add_child parent_node, child_metric
      if (child_node = node child_metric)
        relate parent_node, child_node
      else
        add_new_child parent_node, child_metric
      end
    end

    def add_new_child parent_node, child_metric
      child = Node.new child_metric, [], []
      relate parent_node, child
      @nodes << child
      add_children child
    end

    # add a connection between parent_node and child_node to the tree
    def relate parent, child
      raise_loop_error parent, child if parent.ancestors.include? child.metric.id

      parent.children << child
      add_ancestry child, parent
    end

    def add_ancestry child, parent
      child.ancestors += parent.ancestors + [parent.metric.id]
      child.ancestors.uniq!
      child.children.each { |descendant| add_ancestry descendant, parent }
    end

    def raise_loop_error n1, n2
      raise "calculation loop: #{n1.metric.name} and #{n2.metric.name} " \
              "depend on each other"
    end
  end
end
