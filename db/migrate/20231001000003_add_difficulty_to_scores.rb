class AddDifficultyToScores < ActiveRecord::Migration[7.0]
  def change
    add_column :scores, :difficulty, :string, default: 'beginner', null: false
    add_index :scores, :difficulty
  end
end