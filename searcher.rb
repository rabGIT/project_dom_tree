require_relative 'structs'
require_relative 'renderer'
require_relative 'parser'

# search through a dom tree and match attributes
class Searcher
  def initialize(tree)
    @root = tree
    @search_results = []
  end

  def search_by(type, value)
    search_descendants(@root, type, value)
  end

  def search_descendants(node, type, value)
    @search_results = []
    if value.is_a?(Regexp)
      search_proc = proc { |n| @search_results << n if n.attributes[type] && n.attributes[type].to_s.match(value)}
    else
      search_proc = proc { |n| @search_results << n if n.attributes[type] && n.attributes[type].to_s.match(value + '\b')}
    end
    traverse(node, search_proc)
    @search_results
  end

  def search_ancestors(node, type, value)
    @search_results = []
    while node
      if value.is_a?(Regexp)
        @search_results << node if (node.attributes[type] && node.attributes[type].to_s.match(value))
      else
        @search_results << node if (node.attributes[type] && node.attributes[type].to_s.match(value + '\b'))
      end
      node = node.parent
    end
    @search_results
  end

  private

  # traverse all nodes starting at node and apply proc to it
  def traverse(node, proc)
    return if node.children.nil?
    node.children.each do |n|
      proc.call(n)
      traverse(n, proc)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  p1 = Parser.new("test.html")
  p1.parse
  r1 = Renderer.new(p1.tree)
#  r1.print_html
  s1 = Searcher.new(p1.tree)
  class_em = s1.search_by(:classes, 'emphasized')
  type_head = s1.search_by(:type, /^head$/)
  type_head.each do |result|
    r1.print_stats(result)
  end
  class_em.each do |result|
    r1.print_stats(result)
    ancestors = s1.search_ancestors(result, :type, 'html')
    r1.print_stats(ancestors[0])
  end
end
