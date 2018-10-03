class Card
  # Build a tree of formula dependency
  class DependencyTree
    Node = Struct.new :metric, :children, :parent_cnt

    def initialize root_metrics
      @roots = root_metrics.uniq.map { |metric| Node.new(metric, [], 0) }
    end

    # iterate over all metrics in the tree
    def each_metric
      build_tree
      while @tree.present?
        @tree.sort_by!(&:parent_cnt).reverse!
        yield pop_node.metric
      end
    end

    private

    def pop_node
      node = @tree.pop
      node.children.each do |child|
        raise_loop_error(node, child) unless @tree.include? child
        child.parent_cnt -= 1
      end
      node
    end

    def build_tree
      @tree = @roots.clone
      @roots.each { |node| add_children node }
    end

    def node metric
      @tree.find { |n| n.metric == metric }
    end

    def add_children node
      node.metric.directly_dependent_formula_metrics.each do |metric|
        add_child node, metric
      end
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
