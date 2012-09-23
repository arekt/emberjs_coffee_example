class Article < ActiveRecord::Base
  attr_accessible :content, :title, :id
  has_many :words
end
