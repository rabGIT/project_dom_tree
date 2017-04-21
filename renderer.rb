require_relative 'structs.rb'
require_relative 'parser'

class Renderer
  def initialize(tree)
    @root = tree
    @count = {}
  end

  def print_tree(node = @root, indent = 0, html_only = false)
    indent += 3
    print '   '.rjust(indent)
    puts "#{node.type.ljust(40 - indent)}#{node.attributes unless html_only}"
    return if node.children.nil?
    node.children.each do |n|
      print_tree(n, indent, html_only)
    end
  end

  def print_html(node = @root)
    print_tree(@root, 0, true)
  end

  def print_stats(node = @root)
    puts "Node: #{node.type.ljust(40)}"
    puts "Attributes: #{node.attributes}"
    @count = {}
    counter = proc { |n| @count[n.attributes.type] = (@count[n.attributes.type] ? @count[n.attributes.type] += 1 : 1 )}
    traverse(node, counter)
    puts 'Count of descendant node types: '
    @count.each do |type|
      puts "   #{type[0]}: #{type[1]}"
    end
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
  p = Parser.new("< !doctype html><div>  div text before  <p>    p text  </p>  <div>    more div text  </div>  div text after</div>")
  p.parse
  r = Renderer.new(p.tree)
  r.print_html
  r.print_tree
  p1 = Parser.new("test.html")
  p1.parse
  r1 = Renderer.new(p1.tree)
  r1.print_html
  r1.print_tree
  r1.print_stats
end
