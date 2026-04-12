class Cell < ApplicationRecord
  belongs_to :game
  
  validates :row, :col, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :state, presence: true, inclusion: { in: %w[hidden revealed flagged] }
  validates :neighbor_mines, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 8 }
  
  # Check if the cell is revealed
  def revealed?
    state == 'revealed'
  end
  
  # Check if the cell is hidden
  def hidden?
    state == 'hidden'
  end
  
  # Check if the cell is flagged
  def flagged?
    state == 'flagged'
  end
end