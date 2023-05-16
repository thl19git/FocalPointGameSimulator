public class Server {
  private ArrayList<Agent> originalAgents;
  private HashMap<GridPosition, Monument> originalMonuments;
  private ArrayList<Agent> agents;
  private int nextAgentID;
  private HashMap<GridPosition, Monument> monuments;
  private ArrayList<District> districts;
  private int[] originalGridOccupancy;
  private int[] gridOccupancy;
  private int[] oldGridOccupancy;
  private HashMap<Integer, Boolean> voteResults;
  private int framesToMove;
  private int framesForClustering;
  private int framesForVotes;
  private int movementRounds;
  private int roundsRemaining;
  private boolean paused;
  private GameStage stage;
  private SubgameHandler subgameHandler;
  private DataLogger dataLogger;
  private boolean savedJSON;
  
  Server() {
    resetCollections();
    reset();
    nextAgentID = 1000;
    
  }
  
  private void resetCollections() {
    districts = new ArrayList<District>();
    monuments = new HashMap<GridPosition, Monument>();
    originalMonuments = new HashMap<GridPosition, Monument>();
    agents = new ArrayList<Agent>();
    originalAgents = new ArrayList<Agent>();
    int gridSize = config.getGridSize();
    gridOccupancy = new int[gridSize*gridSize];
    originalGridOccupancy = new int[gridSize*gridSize];
  }
  
  private void softReset() {
    dataLogger = new DataLogger();
    subgameHandler = new SubgameHandler();
    paused = false;
    stage = GameStage.CONFIGURATION;
    agentColors = INITIAL_AGENT_COLORS.clone(); // global variable, not local
    resetCounters();
    visInfoPanel.reset(); // global object, not local
  }
  
  public void hardReset() {
    softReset();
    resetCollections();
  }
  
  public void reset() {
    softReset();
    agents = originalAgents;
    monuments = originalMonuments;
    gridOccupancy = originalGridOccupancy;
  }
  
  private void storeOriginalAgents() {
    originalAgents = new ArrayList<Agent>(agents.size());
    for (Agent agent : agents) {
      originalAgents.add(agent.clone());
    }
  }
  
  private void storeOriginalMonuments() {
    originalMonuments = new HashMap<GridPosition, Monument>();
    for (Monument monument : monuments.values()) {
      Monument clone = monument.clone();
      GridPosition position = monument.getPosition();
      originalMonuments.put(position, clone);
    }
  }
  
  private void beginGame() {
    paused = false;
    storeOriginalAgents();
    storeOriginalMonuments();
    originalGridOccupancy = gridOccupancy.clone();
    createAgents();
    createMonuments();
    dataLogger.init();
    dataLogger.logConfig(config);
    savedJSON = false;
    stage = GameStage.START;
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
  
  public boolean tryAddAgent(GridPosition position) {
    if (gridOccupancy[positionToIndex(position)] == config.getMaxGridOccupancy() || agents.size() == config.getNumAgents()) {
      return false;
    }
    incrementGridOccupancy(position);
    int positionInBox = gridOccupancyAtPosition(position);
    //Agent agent = new Agent(nextAgentID++, position, positionInBox);
    Agent agent = new SmarterAgent(nextAgentID++, position, positionInBox); //Let's see how this lot does!!
    agents.add(agent);
    return true;
  }
  
  private void createAgents() {
    GridPosition randomPosition;
    while (agents.size() < config.getNumAgents()) {
      randomPosition = randomGridPosition();
      tryAddAgent(randomPosition);
    }
  }
  
  public boolean tryAddMonument(GridPosition position) {
    if (monuments.containsKey(position) || monuments.size() == config.getNumMonuments()) {
      return false;
    }
    Monument monument = new Monument(position,"Hi",config.getMonumentVisibility());
    monuments.put(position, monument);
    return true;
  }
  
  private void createMonuments() {
    GridPosition randomPosition;
    while (monuments.size() < config.getNumMonuments()) {
        randomPosition = randomGridPosition();
        tryAddMonument(randomPosition);
    }
  }
  
  public void togglePaused() {
    paused = !paused;
  }
  
  public ArrayList<Agent> getAgents() {
    return agents;
  }
  
  public ArrayList<Monument> getMonuments() {
    return new ArrayList<Monument>(monuments.values());
  }
  
  public ArrayList<District> getDistricts() {
    return districts;
  }
  
  public int getFramesToMove() {
    return framesToMove;
  }
  
  public boolean districtsOverlap(District d1, District d2) {
    if (d1.getBottomRight().getY() < d2.getTopLeft().getY() || d2.getBottomRight().getY() < d1.getTopLeft().getY()) {
      return false;
    }
    if (d1.getTopLeft().getX() > d2.getBottomRight().getX() || d2.getTopLeft().getX() > d1.getBottomRight().getX()) {
      return false;
    }
    return true;
  }
  
  public boolean tryAddDistrict(District newDistrict) {
    for (District district : districts) {
      if (districtsOverlap(district, newDistrict)) {
        return false;
      }
    }
    districts.add(newDistrict);
    return true;
  }
  
  public boolean containsDistricts() {
    return districts.size() > 0;
  }
  
  public boolean containsMonuments() {
    return monuments.size() > 0; 
  }
  
  public boolean containsAgents() {
    return agents.size() > 0;
  }
  
  public boolean containsPlacedObjects() {
    return containsDistricts() || containsMonuments() || containsAgents();
  }
  
  public void removePlacedObjects() {
    districts = new ArrayList<District>();
    monuments = new HashMap<GridPosition, Monument>();
    agents = new ArrayList<Agent>();
    resetGridOccupancy();
    nextAgentID = 1000;
  }
  
  public boolean isCompletelyCoveredInDistricts() {
    int totalSquares = config.getGridSize() * config.getGridSize();
    int coveredSquares = 0;
    for (District district : districts) {
      coveredSquares += district.numSquares();
    }
    return coveredSquares == totalSquares;
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
  
  public void startPlacingStage() {
    stage = GameStage.PLACING;
    int gridSize = config.getGridSize();
    gridOccupancy = new int[gridSize*gridSize];
    originalGridOccupancy = new int[gridSize*gridSize];
    visInfoPanel.reset();
  }
  
  public GameStage getStage() {
    return stage;
  }
  
  private void gatherVotes(HashMap<Integer, Integer> votes) {
    int choices = config.getNumChoices();
    for (Agent agent : agents) {
      int vote = agent.voteForChoice(choices, monumentsVisibleForAgent(agent));
      votes.put(agent.getID(), vote);
    }
  }
  
  private void distributeVoteResults() {
    int winCount = 0;
    for (Agent agent : agents) {
      int ID = agent.getID();
      boolean result = voteResults.get(ID);
      agent.receiveVoteResult(result);
      if (result) {
        winCount++;
      }
    }
    float winRate = (float)winCount / config.getNumAgents();
    visInfoPanel.addNewWinRate(winRate);
  }
  
  private void conductVote() {
    int clusters = config.getNumClusters();
    HashMap<Integer, Integer> votes = new HashMap<Integer, Integer>();
    gatherVotes(votes);
    voteResults = subgameHandler.computeResults(clusters, config.getNumChoices(), agents, votes);
    distributeVoteResults();
    handleMonumentEditing(); //Agents can update monuments after receiving game results
    dataLogger.logRound(agents, votes, voteResults, config.getNumClusters());
  }
  
  public boolean getAgentResult(int ID) {
    return voteResults.get(ID);
  }
  
  private ArrayList<Monument> monumentsVisibleForAgent(Agent agent) {
    ArrayList<Monument> visibleMonuments = new ArrayList<Monument>();
    for (Monument monument : monuments.values()) {
      if (monument.canBeSeen(agent.getGridPosition())) {
        visibleMonuments.add(monument);
      }
    }
    return visibleMonuments;
  }
  
  private void handleMonumentViewing() {
    for (Agent agent : agents) {
      agent.viewMonuments(monumentsVisibleForAgent(agent));
    }
  }
  
  private void handleMonumentEditing() {
    for (Agent agent : agents) {
      GridPosition agentPosition = agent.getGridPosition();
      if (monuments.containsKey(agentPosition)) {
        agent.editMonument(monuments.get(agentPosition));
      }
    }
  }
  
  private void startStage() {
    if (roundsRemaining > 0) {
      roundsRemaining--;
      stage = GameStage.MOVE_DECISION;
    } else {
      //printOverallStats();
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
    if (movementRounds == 0) { // Monument viewing happens during vote
      stage = GameStage.CLUSTERING;
      movementRounds = config.getNumMoves();
    } else {
      handleMonumentViewing();
      handleMonumentEditing();
      stage = GameStage.MOVE_DECISION;
    }
  }
  
  private void clusteringStage() {
    if (framesForClustering == SHOW_CLUSTERING_FRAMES) {
      int[] agentsPerCluster = kMeansClustering(config.getNumClusters(), agents);
      visInfoPanel.updateClusterCounts(agentsPerCluster);
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
    if (!savedJSON) {
      dataLogger.saveJSON();
      savedJSON = true;
    }
  }
  
  public void run() {
    if (paused) {
      return;
    }
    
    switch (stage) {
      case CONFIGURATION:
        // Do nothing
        break;
      case PLACING:
        game.update();
        break;
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
