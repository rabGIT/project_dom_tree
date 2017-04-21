Tag = Struct.new(:type, :classes, :id, :name, :title, :src)

def parse_tag(ttp)
  reg_ex = []
  tag_attr = []

  tag_type_re = /<(\w+)\b/
  tag_classes_re = /class\s+?{0,}=\s+?{0,}['"](.+?)['"]/
  tag_id_re = /id\s+?{0,}=\s+?{0,}['"](.+?)['"]/
  tag_name_re = /name\s+?{0,}=\s+?{0,}['"](.+?)['"]/
  tag_title_re = /title\s+?{0,}=\s+?{0,}['"](.+?)['"]/
  tag_src_re = /src\s+?{0,}=\s+?{0,}['"](.+?)['"]/

  reg_ex << tag_type_re
  reg_ex << tag_classes_re
  reg_ex << tag_id_re
  reg_ex << tag_name_re
  reg_ex << tag_title_re
  reg_ex << tag_src_re

  reg_ex.each do |re|
    ttp.match(re).nil? ? tag_attr << nil : tag_attr << ttp.match(re).captures[0]
  end

  tag_attr[1] = tag_attr[1].to_s.split(' ') # split up classes into array

  Tag.new(tag_attr[0], tag_attr[1], tag_attr[2], tag_attr[3], tag_attr[4], tag_attr[5])
end

# test code
if __FILE__ == $PROGRAM_NAME
  puts " #{parse_tag("<p class='foo bar' id='baz' name='fozzie'>")}"
  puts " #{parse_tag("<div id = 'bim'>")}"
  puts " #{parse_tag("<img src='http://www.example.com' title='funny things'>")}"
end
