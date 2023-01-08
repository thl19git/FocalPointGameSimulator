public class Server {
  private ArrayList<Agent> agents;
  private int[] gridOccupancy;
  private int[] oldGridOccupancy;
  private int framesToMove;
  private int framesForClustering;
  private GameStage stage;
  
  Server() {
    resetGridOccupancy();
    createAgents();
    framesToMove = AGENT_MOVE_FRAMES;
    framesForClustering = SHOW_CLUSTERING_FRAMES;
    stage = GameStage.START;
  }
  
  private void resetGridOccupancy() {
    int gridSize = config.getGridSize();
    gridOccupancy = new int[gridSize*gridSize];
  }
  
  private void createAgents() {
    agents = new ArrayList<Agent>();
    
    for (int ID = START_ID; ID < START_ID + config.getNumAgents(); ID++) {
      GridPosition randomPosition;
      
      while (true) {
        randomPosition = randomGridPosition();
        if (gridOccupancy[positionToIndex(randomPosition)] < config.getMaxGridOccupancy()) {
          break;
        }
      }

      incrementGridOccupancy(randomPosition);
      int positionInBox = gridOccupancyAtPosition(randomPosition);
      Agent agent = new Agent(ID, randomPosition, positionInBox);
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
    int occupancy = gridOccupancy[index];
    
    return occupancy < config.getMaxGridOccupancy();
  }
  
  private void decrementGridOccupancy(GridPosition position) {
    changeGridOccupancy(position, -1);
  }
  
  private void incrementGridOccupancy(GridPosition position) {
    changeGridOccupancy(position, 1);
  }
  
  private void changeGridOccupancy(GridPosition position, int amount) {
    int index = positionToIndex(position);
    
    gridOccupancy[index] += amount;
  }
  
  public int gridOccupancyAtIndex(int index) {
    return gridOccupancy[index];
  }
  
  public int gridOccupancyAtPosition(GridPosition position) {
    int index = positionToIndex(position);
    
    return gridOccupancyAtIndex(index);
  }
  
  public int oldGridOccupancyAtIndex(int index) {
    return oldGridOccupancy[index];
  }
  
  public int oldGridOccupancyAtPosition(GridPosition position) {
    int index = positionToIndex(position);
    
    return oldGridOccupancyAtIndex(index);
  }
  
  private void allocateNewInternalPositions() {
    int gridSize = config.getGridSize();
    int allocated[] = new int[gridSize*gridSize];
    for (int index = 0; index < agents.size(); index++) {
        Agent agent = agents.get(index);
        GridPosition nextPosition = agent.getNextGridPosition();
        int gridIndex = positionToIndex(nextPosition);
        allocated[gridIndex]++;
        agent.setNextPositionInBox(allocated[gridIndex]);
    }
  }
  
  public GameStage getStage() {
    return stage;
  }
  
  private void startStage() {
    stage = GameStage.MOVE_DECISION;
  }
  
  private void moveDecisionStage() {
    oldGridOccupancy = gridOccupancy.clone();
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
    allocateNewInternalPositions();
    stage = GameStage.AGENTS_MOVING;
  }
  
  private void agentsMovingStage() {
    decrementFramesToMove();
    if (framesToMove == 0) {
      for (int index = 0; index < agents.size(); index++) {
        Agent agent = agents.get(index);
        agent.reachedNextGridPosition();
      }
      framesToMove = AGENT_MOVE_FRAMES;
      stage = GameStage.COMMUNICATION;
      return;
    }
    game.update();
  }
  
  private void communicationStage() {
    stage = GameStage.CLUSTERING;
  }
  
  private void clusteringStage() {
    if (framesForClustering == SHOW_CLUSTERING_FRAMES) {
      kMeansClustering(agents);
      framesForClustering--;
      game.update();
    } else {
      framesForClustering--;
      if (framesForClustering == 0) {
        stage = GameStage.MOVE_DECISION;
        framesForClustering = SHOW_CLUSTERING_FRAMES;
      }
    }
    
  }
  
  private void votingStage() {
    
  }
  
  private void finishStage() {
    
  }
  
  public void run() {
    switch (stage) {
      case START:
        startStage();
        break;
      case MOVE_DECISION:
        moveDecisionStage();
        break;
      case AGENTS_MOVING:
        agentsMovingStage();
        break;
      case COMMUNICATION:
        communicationStage();
        break;
      case CLUSTERING:
        clusteringStage();
        break;
      case VOTING:
        votingStage();
        break;
      case FINISH:
        finishStage();
        break;
      default:
        println("Stage not implemented, quitting");
        exit();
    }
  }
}
