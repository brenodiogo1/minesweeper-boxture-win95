class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.string :difficulty, null: false
      t.integer :rows, null: false
      t.integer :cols, null: false
      t.integer :mines, null: false
      t.string :state, null: false, default: 'playing'
      t.integer :clicks, default: 0
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end
    
    add_index :games, :state
    add_index :games, :difficulty
  end
end