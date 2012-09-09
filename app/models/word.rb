class Word < ActiveRecord::Base
  attr_accessible :article_id, :desc, :kana, :kanji
end
