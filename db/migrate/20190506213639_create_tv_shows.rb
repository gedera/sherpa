class CreateTvShows < ActiveRecord::Migration[5.2]
  def change
    create_table :tv_shows do |t|
      t.string :title
      t.string :file_name
      t.string :season
      t.string :episode
      t.string :date
      t.string :quality
      t.string :rss
      t.boolean :moved_to_media, default: false, index: true
      t.timestamps
    end
  end
end
