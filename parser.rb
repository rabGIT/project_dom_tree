require_relative 'tag'
require_relative 'structs'

# DOM parser --> HTML in, produces tree with clean print
# initialize with HTML string or filename with HTML
class Parser
  def initialize(filename)
    @buffer = load_file(filename)
    @tokenized = []
    @root = TagNode.new('document', Tag.new('root', nil, nil, nil, nil, nil), nil, [])
  end

  def parse
    tokenize
    parse_to_tree
  end

  def tree
    @root
  end

  private

  # if the file doesn't exist, assume the string is a html input and proceed
  # otherwise, read the file into an array, string \n from each line and then
  # put it back togeter as a string
  def load_file(filename)
    return @buffer = filename unless File.exist?(filename)
    @buffer = File.readlines(filename)
    @buffer.each_with_index do |line, index|
      @buffer[index] = line.chomp
    end
    @buffer = @buffer.join
  end

  # load @tokenized as an array with each html element as a separate array
  # element including text as a token
  def tokenize
    re_tag = /^(<.+?>)(.+)/
    re_text = /(.+?)(<.+)/
    until @buffer.empty?
      parse = @buffer.match(re_tag) ? @buffer.match(re_tag) : @buffer.match(re_text)
      return @tokenized << @buffer if parse.nil?
      @tokenized << parse.captures[0]
      @buffer = parse.captures[1].strip
    end
  end

  # take the tokenized array and transalte into a tree structure using regex
  # to match on token types to put them at the right level in the DOM tree
  def parse_to_tree
    node = @root
    @tokenized.each do |e|
      if e.match(/^<[\/].+>/)
        node = node.parent
        node.children << TagNode.new(e, Tag.new((e.match(/<(.+?)>/).captures[0]), nil, nil, nil, nil, nil), node, [])
      elsif e.match(/^<img.+?>|^<hr.+?>|^<!doctype.+?>/)
        node.children << TagNode.new(e, Tag.new((e.match(/<(.+?)>/).captures[0]), nil, nil, nil, nil, nil), node, [])
      elsif e.match(/<.+>/)
        node.children << TagNode.new(e, parse_tag(e), node, [])
        node = node.children[-1]
      else
        node.children << TagNode.new(e, Tag.new('text', nil, nil, nil, nil, nil), node, [])
      end
    end
  end
end

# test code
if __FILE__ == $PROGRAM_NAME
  p = Parser.new("< !doctype html><div>  div text before  <p>    p text  </p>  <div>    more div text  </div>  div text after</div>")
  p.parse
  p1 = Parser.new("test.html")
  p1.parse
end
