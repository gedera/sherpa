class CreateMovies < ActiveRecord::Migration[6.0]
  def change
    create_table :movies do |t|
      t.string :title
      t.string :file_name
      t.integer :year
      t.string :quality
      t.integer :state
      t.string :telegram_id
      t.timestamps
    end
  end
end
