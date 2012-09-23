require 'kanji_dictionary'
class DemoController < ApplicationController
  def index
    Rails.logger.debug "DEBUG: Demo/index"
  end
  def dictionary
    dictionary = KanjiDictionary.new
    result = dictionary.search(params[:name])
    Rails.logger.debug "Dictionary said: #{result}"
    render :json => result.sort { |a,b| 
      a[1].length <=> b[1].length 
    }.each_with_index.select{ |r,i| 
        i < 5 }.map(&:first)
  end
end
