require_relative 'tag'

TagNode = Struct.new(:type, :attributes, :parent, :children)

class Parser
  def initialize(html_str)
    @buffer = html_str
    @tokenized = []
    @root = TagNode.new('document', nil, nil, [])
    @tag = /^(<.+?>)(.+)/
    @text = /(.+?)(<.+)/
  end

  def parse
    tokenize
    parse_to_tree
    print_tree(@root)
  end

  def tokenize
    until @buffer.empty?
      parse = @buffer.match(@tag) ? @buffer.match(@tag) : @buffer.match(@text)
      return @tokenized << @buffer if parse.nil?
      @tokenized << parse.captures[0]
      @buffer = parse.captures[1].strip
    end
  end

  def parse_to_tree
    node = @root
    @tokenized.each do |e|
      if e.match(/^<[\/].+>/)
        node = node.parent
        node.children << TagNode.new(e, nil, node, [])
      elsif e.match(/<.+>/)
        node.children << TagNode.new(e, parse_tag(e), node, [])
        node = node.children[-1]
      else
        node.children << TagNode.new(e, nil, node, [])
      end
    end
  end

  def print_tree(node, indent = 0)
    indent += 3
    print '   '.rjust(indent)
    puts "#{node.type} #{node.attributes}"
    return if node.children.nil?
    node.children.each do |n|
      print_tree(n, indent)
    end
  end


end



# test code
if __FILE__ == $PROGRAM_NAME
  p = Parser.new("<div>  div text before  <p>    p text  </p>  <div>    more div text  </div>  div text after</div>")
  p.parse
  p1 = Parser.new("<p>Before text <span>mid text (not included in text attribute of the paragraph tag)</span> after text</p>")
  p1.parse
end
