public class Server {
  private ArrayList<Agent> agents;
  private int[] gridOccupancy;
  private int[] oldGridOccupancy;
  private boolean[] voteResults;
  private int framesToMove;
  private int framesForClustering;
  private int framesForVotes;
  private int movementRounds;
  private int roundsRemaining;
  private GameStage stage;
  
  Server() {
    reset();
    createAgents();
    stage = GameStage.START;
  }
  
  private void reset() {
    resetGridOccupancy();
    resetCounters();
  }
  
  private void resetCounters() {
    framesToMove = AGENT_MOVE_FRAMES;
    framesForClustering = SHOW_CLUSTERING_FRAMES;
    framesForVotes = SHOW_VOTES_FRAMES;
    movementRounds = config.getNumMoves();
    roundsRemaining = config.getNumRounds();
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
    for (Agent agent : agents) {
        GridPosition nextPosition = agent.getNextGridPosition();
        int gridIndex = positionToIndex(nextPosition);
        allocated[gridIndex]++;
        agent.setNextPositionInBox(allocated[gridIndex]);
    }
  }
  
  public GameStage getStage() {
    return stage;
  }
  
  private void gatherVotes(ArrayList<HashSet<Integer>> votes) {
    int choices = config.getNumChoices();
    for (Agent agent : agents) {
      int agentCluster = agent.getClusterNumber();
      int vote = agent.voteForChoice(choices);
      votes.get(agentCluster).add(vote);
    }
  }
  
  private void calculateVoteResults(ArrayList<HashSet<Integer>> votes) {
    int clusters = config.getNumClusters();
    voteResults = new boolean[clusters];
    
    for (int cluster = 0; cluster < clusters; cluster++) {
      voteResults[cluster] = votes.get(cluster).size() == 1;
    }
  }
  
  private void distributeVoteResults() {
    for (Agent agent : agents) {
      int cluster = agent.getClusterNumber();
      boolean result = voteResults[cluster];
      agent.receiveVoteResult(result);
    }
  }
  
  private void conductVote() {
    int clusters = config.getNumClusters();
    ArrayList<HashSet<Integer>> votes = new ArrayList<HashSet<Integer>>();
    
    for (int cluster = 0; cluster < clusters; cluster++) {
      HashSet<Integer> set = new HashSet<Integer>();
      votes.add(set);
    }
    
    gatherVotes(votes);
    calculateVoteResults(votes);
    distributeVoteResults();
  }
  
  public boolean getClusterResult(int cluster) {
    return voteResults[cluster];
  }
  
  private void startStage() {
    roundsRemaining--;
    if (roundsRemaining > 0) {
      stage = GameStage.MOVE_DECISION;
    } else {
      stage = GameStage.FINISH;
    }
  }
  
  private void moveDecisionStage() {
    oldGridOccupancy = gridOccupancy.clone();
    for (Agent agent : agents) {
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
    framesToMove--;
    if (framesToMove == 0) {
      for (Agent agent : agents) {
        agent.reachedNextGridPosition();
      }
      framesToMove = AGENT_MOVE_FRAMES;
      stage = GameStage.COMMUNICATION;
      return;
    }
    game.update();
  }
  
  private void communicationStage() {
    movementRounds--;
    if (movementRounds == 0) {
      stage = GameStage.CLUSTERING;
      movementRounds = config.getNumMoves();
    } else {
      stage = GameStage.MOVE_DECISION;
    }
  }
  
  private void clusteringStage() {
    if (framesForClustering == SHOW_CLUSTERING_FRAMES) {
      kMeansClustering(agents);
      game.update();
    }
    framesForClustering--;
    if (framesForClustering == 0) {
      stage = GameStage.VOTING;
      framesForClustering = SHOW_CLUSTERING_FRAMES;
    }
  }
  
  private void votingStage() {
    if (framesForVotes == SHOW_VOTES_FRAMES) {
      conductVote();
      game.update();
    }
    framesForVotes--;
    if (framesForVotes == 0) {
      stage = GameStage.START;
      framesForVotes = SHOW_VOTES_FRAMES;
    }
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
