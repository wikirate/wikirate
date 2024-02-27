class Card
  # Build a tree of metrics that depend on a given calculated metric (when dependency
  # type is :dependee) or that the metrics depends on or
  class DependencyTree
    Node = Struct.new :metric, :children, :parent_cnt

    # @param root_metrics [Array] list of first level dependencies
    # @param dependency_type [Symbol] either :depender or :dependee
    def initialize dependency_type, metric
      @dependency_type = dependency_type
      @roots = children_for_metric(metric).uniq.map { |metric| Node.new(metric, [], 0) }
    end

    def each_metric &block
      metrics.each(&block)
    end

    def metrics
      @metrics ||= pluck_metrics
    end

    def tree
      @tree ||= build_tree
    end

    private

    # iterate over all metrics in the tree
    # note: this deconstructs the tree. Can only run once
    def pluck_metrics
      build_tree
      [].tap do |metrics|
        while @tree.present?
          @tree.sort_by!(&:parent_cnt).reverse!
          metrics << pop_node.metric
        end
      end
    end

    def pop_node
      node = @tree.pop
      node.children.each do |child|
        raise_loop_error(node, child) unless @tree.include? child
        child.parent_cnt -= 1
      end
      node
    end

    # each node has
    # - metric
    # - children (for depender tree: children nodes are dependers for metrics.
    #   for dependee trees, children are dependees)
    # - parent_cnt (for depender tree, number of dependees. for dependee tree, number of
    #   dependers)
    #
    #
    # @roots is a fixed list of nodes with no child/parent info
    #
    # build_tree creates a @tree object. every child object also appears in the root.
    # so maybe not super efficient ¯\_(ツ)_/¯
    def build_tree
      @tree = @roots.clone
      @roots.each { |node| add_children node }
      @tree
    end

    def node metric
      @tree.find { |n| n.metric == metric }
    end

    def add_children node
      children_for_metric(node.metric).each { |metric| add_child node, metric }
    end

    def children_for_metric metric
      metric.send "direct_#{@dependency_type}_metrics"
    end

    def add_child parent_node, child_metric
      if (child = node(child_metric))
        child.parent_cnt += 1
        relate parent_node, child
      else
        add_new_child parent_node, child_metric
      end
    end

    def add_new_child parent_node, child_metric
      child = Node.new(child_metric, [], 1)
      @tree << child
      relate parent_node, child
      add_children child
    end

    # add a connection between parent_node and child_node to the tree
    def relate parent_node, child_node
      raise_loop_error parent_node, child_node if parent_node.children.include? child_node
      parent_node.children << child_node
    end

    def raise_loop_error n1, n2
      raise "calculation loop: #{n1.metric.name} and #{n2.metric.name} " \
              "depend on each other"
    end
  end
end
