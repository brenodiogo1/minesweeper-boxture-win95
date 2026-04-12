class ScoresController < ApplicationController
  def index
    @difficulty = params[:difficulty] || 'beginner'
    @scores = Score.by_difficulty(@difficulty).top_scores(10)
    @all_difficulties = %w[beginner intermediate expert]
  end

  def new
    @game = Game.find(params[:game_id])
    
    # Verifica se o jogo foi ganho
    unless @game.state == 'won'
      redirect_to game_path(@game), alert: 'You need to win the game first!'
      return
    end

    # Verifica se já existe um score para este jogo
    if Score.exists?(total_score: Score.calculate_score(@game.clicks, @game.time_taken), 
                     clicks: @game.clicks, 
                     time_taken: @game.time_taken,
                     difficulty: @game.difficulty)
      redirect_to scores_path(difficulty: @game.difficulty), notice: 'Score already saved!'
      return
    end

    @score = Score.new
  end

  def create
    @game = Game.find(params[:game_id])
    
    # Verifica novamente se o jogo foi ganho
    unless @game.state == 'won'
      redirect_to game_path(@game), alert: 'You need to win the game first!'
      return
    end

    @score = Score.new(score_params)
    @score.clicks = @game.clicks
    @score.time_taken = @game.time_taken
    @score.difficulty = @game.difficulty
    @score.total_score = Score.calculate_score(@game.clicks, @game.time_taken)

    if @score.save
      redirect_to scores_path(difficulty: @game.difficulty), notice: 'Score saved successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def score_params
    params.require(:score).permit(:player_name)
  end
end