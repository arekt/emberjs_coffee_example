class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :kanji
      t.string :kana
      t.string :desc
      t.string :article_id

      t.timestamps
    end
  end
end
