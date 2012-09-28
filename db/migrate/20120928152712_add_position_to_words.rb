class AddPositionToWords < ActiveRecord::Migration
  def change
    add_column :words, :position, :integer
  end
end
