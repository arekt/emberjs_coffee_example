require 'kanji_dictionary'
class DemoController < ApplicationController
  layout 'ember'     
  def index

  end
  def dictionary
    dictionary = KanjiDictionary.new
    result = dictionary.search(params[:name]).to_json
    Rails.logger.debug "Dictionary said: #{result}"
    render :json => result
  end
end
