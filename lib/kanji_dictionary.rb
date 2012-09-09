# encoding: utf-8
require 'open-uri'
class KanjiDictionary
  def search(q)
    @answers = `grep #{q} ./edict-utf8`
    puts @answers.inspect
    @answers.scan(/(.*)(\[.*\])(.*)/)
    #.select do |a|
    #  a[0].match(/^q/)
    #end 
  end
end


if __FILE__ == $0
  @dic = KanjiDictionary.new
  puts @dic.search("おんな")
end
