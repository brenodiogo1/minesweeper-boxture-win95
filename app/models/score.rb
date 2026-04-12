class Score < ApplicationRecord
  validates :player_name, presence: true, length: { minimum: 1, maximum: 50 }
  validates :clicks, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :time_taken, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :total_score, presence: true, numericality: { only_integer: true }
  validates :difficulty, presence: true, inclusion: { in: %w[beginner intermediate expert] }

  # Scope para ordenar por melhor score (maior é melhor)
  scope :top_scores, ->(limit = 10) { order(total_score: :desc).limit(limit) }
  scope :by_difficulty, ->(difficulty) { where(difficulty: difficulty) }

  # Calcula o score total baseado em clicks e tempo
  # Formula: 10000 - (clicks * 10) - (time * 5)
  # Quanto menor clicks e tempo, maior o score
  def self.calculate_score(clicks, time_taken)
    10000 - (clicks * 10) - (time_taken * 5)
  end
end