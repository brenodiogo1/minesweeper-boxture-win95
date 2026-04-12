class GamesController < ApplicationController
  before_action :set_game, only: [:show, :reveal_cell, :toggle_flag]

  def index
  end

  def create
    difficulty = params[:difficulty] || 'beginner'
    
    dimensions = case difficulty
    when 'beginner'
      { rows: 9, cols: 9, mines: 10 }
    when 'intermediate'
      { rows: 16, cols: 16, mines: 40 }
    when 'expert'
      { rows: 16, cols: 30, mines: 99 }
    else
      { rows: 9, cols: 9, mines: 10 }
    end

    @game = Game.create!(
      difficulty: difficulty,
      rows: dimensions[:rows],
      cols: dimensions[:cols],
      mines: dimensions[:mines],
      state: 'playing',
      clicks: 0
    )

    MinesweeperEngine.initialize_board(@game)

    redirect_to game_path(@game)
  end

  def show
  end

  def reveal_cell
    row = params[:row].to_i
    col = params[:col].to_i

    cell = @game.cells.find_by(row: row, col: col)
    
    # Don't reveal flagged cells
    if cell && cell.state == 'flagged'
      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { redirect_to game_path(@game) }
      end
      return
    end

    # Start timer on first click
    if @game.started_at.nil?
      @game.update(started_at: Time.current)
    end

    # Increment clicks only for valid reveals
    if cell && cell.state == 'hidden'
      @game.increment!(:clicks)
      MinesweeperEngine.reveal_cell(@game, row, col)
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("game-board", partial: "games/board", locals: { game: @game }),
          turbo_stream.replace("game-stats", partial: "games/stats", locals: { game: @game })
        ]
      end
      format.html { redirect_to game_path(@game) }
    end
  end

  def toggle_flag
    row = params[:row].to_i
    col = params[:col].to_i

    cell = @game.cells.find_by(row: row, col: col)
    
    if cell && !@game.finished?
      if cell.state == 'hidden'
        cell.update(state: 'flagged')
      elsif cell.state == 'flagged'
        cell.update(state: 'hidden')
      end
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("game-board", partial: "games/board", locals: { game: @game }),
          turbo_stream.replace("game-stats", partial: "games/stats", locals: { game: @game })
        ]
      end
      format.html { redirect_to game_path(@game) }
    end
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end
end