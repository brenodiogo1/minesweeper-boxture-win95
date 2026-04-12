class MinesweeperEngine
  def self.initialize_board(game)
    # Create all cells for rectangular grid
    game.rows.times do |row|
      game.cols.times do |col|
        game.cells.create!(
          row: row,
          col: col,
          is_mine: false,
          state: 'hidden',
          neighbor_mines: 0
        )
      end
    end
  end

  def self.place_mines(game, first_row, first_col)
    # Generate all possible coordinates
    all_coordinates = []
    game.rows.times do |row|
      game.cols.times do |col|
        all_coordinates << [row, col]
      end
    end

    # Remove first click position and its neighbors (safe zone)
    safe_zone = [[first_row, first_col]]
    neighbors = get_neighbors(game, first_row, first_col)
    safe_zone += neighbors.map { |n| [n[:row], n[:col]] }
    
    available_coordinates = all_coordinates - safe_zone

    # Randomly select unique mine positions
    mine_positions = available_coordinates.sample(game.mines)

    # Place mines
    mine_positions.each do |row, col|
      cell = game.cells.find_by(row: row, col: col)
      cell.update!(is_mine: true)
    end

    # Calculate neighbor counts for all non-mine cells
    calculate_all_neighbors(game)
  end

  def self.calculate_all_neighbors(game)
    game.cells.where(is_mine: false).each do |cell|
      neighbors = get_neighbors(game, cell.row, cell.col)
      mine_count = neighbors.count { |n| n[:is_mine] }
      cell.update!(neighbor_mines: mine_count)
    end
  end

  def self.get_neighbors(game, row, col)
    neighbors = []
    
    # 8 directions: top, bottom, left, right, and 4 diagonals
    [
      [-1, -1], [-1, 0], [-1, 1],  # top-left, top, top-right
      [0, -1],           [0, 1],    # left, right
      [1, -1],  [1, 0],  [1, 1]     # bottom-left, bottom, bottom-right
    ].each do |dr, dc|
      new_row = row + dr
      new_col = col + dc
      
      # Check boundaries
      if new_row >= 0 && new_row < game.rows && new_col >= 0 && new_col < game.cols
        neighbor = game.cells.find_by(row: new_row, col: new_col)
        neighbors << { row: new_row, col: new_col, is_mine: neighbor.is_mine } if neighbor
      end
    end
    
    neighbors
  end

  def self.reveal_cell(game, row, col)
    cell = game.cells.find_by(row: row, col: col)
    
    return if cell.nil?
    return if cell.state == 'revealed'
    return if cell.state == 'flagged'

    # First click: place mines if not placed yet
    if game.cells.where(is_mine: true).count == 0
      place_mines(game, row, col)
      cell.reload
    end

    # Reveal the cell
    cell.update!(state: 'revealed')

    # Check if mine
    if cell.is_mine
      game.update!(state: 'lost', finished_at: Time.current)
      reveal_all_mines(game)
      return
    end

    # If zero neighbors, flood fill
    if cell.neighbor_mines == 0
      flood_fill(game, row, col)
    end

    # Check win condition
    check_win_condition(game)
  end

  def self.flood_fill(game, start_row, start_col)
    # BFS (Breadth-First Search) to avoid stack overflow
    queue = [[start_row, start_col]]
    visited = Set.new

    while queue.any?
      row, col = queue.shift
      next if visited.include?([row, col])
      visited.add([row, col])

      neighbors = get_neighbors(game, row, col)
      
      neighbors.each do |neighbor_data|
        n_row = neighbor_data[:row]
        n_col = neighbor_data[:col]
        
        next if visited.include?([n_row, n_col])
        
        neighbor_cell = game.cells.find_by(row: n_row, col: n_col)
        next if neighbor_cell.nil?
        next if neighbor_cell.state == 'revealed'
        next if neighbor_cell.state == 'flagged'
        next if neighbor_cell.is_mine

        # Reveal this neighbor
        neighbor_cell.update!(state: 'revealed')

        # If it's also a zero, add to queue for expansion
        if neighbor_cell.neighbor_mines == 0
          queue << [n_row, n_col]
        end
      end
    end
  end

  def self.reveal_all_mines(game)
    game.cells.where(is_mine: true).update_all(state: 'revealed')
  end

  def self.check_win_condition(game)
    total_cells = game.rows * game.cols
    revealed_cells = game.cells.where(state: 'revealed').count
    
    # Win if all non-mine cells are revealed
    if revealed_cells == total_cells - game.mines
      game.update!(state: 'won', finished_at: Time.current)
    end
  end
end