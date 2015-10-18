class Sitemap < Hash
  def to_dot
    output = ''
    output +=  "digraph sitemap {\n"
    each do |source, targets|
      targets.each do |target|
        output +=  "  #{source} -> #{target}\n"
      end
    end
    output += "}\n"
    output
  end
end
