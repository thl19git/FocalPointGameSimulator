public class Server {
  private ArrayList<Agent> agents;
  private ArrayList<Integer> gridOccupancy;
  private int framesToMove;
  private boolean agentsMoving;
  
  Server() {
    resetGridOccupancy();
    createAgents();
    framesToMove = AGENT_MOVE_FRAMES;
    agentsMoving = false;
  }
  
  private void resetGridOccupancy() {
    int gridSize = config.getGridSize();
    gridOccupancy = new ArrayList<Integer>(Collections.nCopies(gridSize*gridSize, 0));
  }
  
  private void createAgents() {
    agents = new ArrayList<Agent>();
    
    int gridSize = config.getGridSize();
    for (int ID = START_ID; ID < START_ID + config.getNumAgents(); ID++) {
      int randomPosition;
      
      while (true) {
        randomPosition = floor(random(gridSize*gridSize));
        if (gridOccupancy.get(randomPosition) < MAX_GRID_OCCUPANCY) {
          break;
        }
        println("Sqaure ", randomPosition," is full");
      }
      
      println("Creating agent at, ", randomPosition);
      
      GridPosition initialPosition = new GridPosition(randomPosition % gridSize, randomPosition / gridSize);
      incrementGridOccupancy(initialPosition);
      Agent agent = new Agent(ID, initialPosition);
      agents.add(agent);
    }
  }
  
  public ArrayList<Agent> getAgents() {
    return agents;
  }
  
  private void decrementFramesToMove() {
    framesToMove--;
  }
  
  public int getFramesToMove() {
    return framesToMove;
  }
  
  public boolean getAgentsMoving() {
    return agentsMoving;
  }
  
  public void toggleAgentsMoving() {
    agentsMoving = !agentsMoving;
    framesToMove = AGENT_MOVE_FRAMES;
  }
  
  private ArrayList<GridPosition> getValidPositions(GridPosition position) {
    ArrayList<GridPosition> validPositions = new ArrayList<GridPosition>();
    validPositions.add(position); //Current position is valid
    
    int x = position.getX();
    int y = position.getY();
    
    if (x > 0 && positionHasSpace(x-1, y)) {
      validPositions.add(new GridPosition(x-1, y));
    }
    if (x < config.getGridSize() - 1 && positionHasSpace(x+1, y)) {
      validPositions.add(new GridPosition(x+1, y));
    }
    if (y > 0 && positionHasSpace(x, y-1)) {
      validPositions.add(new GridPosition(x, y-1));
    }
    if (y < config.getGridSize() - 1 && positionHasSpace(x, y+1)) {
      validPositions.add(new GridPosition(x, y+1));
    }
    return validPositions;
  }
  
  private boolean positionHasSpace(int x, int y) {
    int index = x + config.getGridSize() * y;
    Integer occupancy = gridOccupancy.get(index);
    
    return occupancy < MAX_GRID_OCCUPANCY;
  }
  
  private void decrementGridOccupancy(GridPosition position) {
    changeGridOccupancy(position, -1);
  }
  
  private void incrementGridOccupancy(GridPosition position) {
    changeGridOccupancy(position, 1);
  }
  
  private void changeGridOccupancy(GridPosition position, int amount) {
    int x = position.getX();
    int y = position.getY();
    
    int index = x + config.getGridSize() * y;
    
    Integer occupancy = gridOccupancy.get(index);
    occupancy += amount;
    gridOccupancy.set(index, occupancy);
  }
  
  public void run() {
    if (agentsMoving == false) {
      for (int index = 0; index < agents.size(); index++) {
        Agent agent = agents.get(index);
        GridPosition position = agent.getGridPosition();
        ArrayList<GridPosition> validPositions = getValidPositions(position);
        int nextPositionIndex = agent.chooseNextGridPosition(validPositions);
        agent.setNextGridPosition(validPositions.get(nextPositionIndex));
        
        if (validPositions.get(nextPositionIndex) != position) { // i.e. moving square
          decrementGridOccupancy(position);
          incrementGridOccupancy(validPositions.get(nextPositionIndex));
        }
      }
      toggleAgentsMoving();
    } else {
      decrementFramesToMove();
      if (framesToMove == 0) {
        toggleAgentsMoving();
        for (int index = 0; index < agents.size(); index++) {
          Agent agent = agents.get(index);
          agent.reachedNextGridPosition();
        }
      }
      
      game.update();
    }
  }
}
