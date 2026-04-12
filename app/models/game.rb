class Game < ApplicationRecord
  has_many :cells, dependent: :destroy

  validates :difficulty, presence: true
  validates :rows, :cols, :mines, presence: true, numericality: { greater_than: 0 }

  def won?
    state == 'won'
  end

  def lost?
    state == 'lost'
  end

  def finished?
    won? || lost?
  end

  def remaining_mines
    flagged_count = cells.where(state: 'flagged').count
    mines - flagged_count
  end

  def elapsed_time
    return 0 unless started_at
    
    end_time = finished_at || Time.current
    ((end_time - started_at).to_i).clamp(0, 999)
  end
end