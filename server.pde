public class Server {
  private ArrayList<Agent> originalAgents;
  private HashMap<GridPosition, Monument> originalMonuments;
  private ArrayList<Agent> agents;
  private int nextAgentID;
  private int nextDistrictNumber;
  private HashMap<GridPosition, Monument> monuments;
  private ArrayList<District> districts;
  private HashMap<GridPosition, Integer> districtAtPosition;
  private FractionalGridPosition[] centroidPositions;
  private float[] clusterDistancesToMonuments;
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
    nextDistrictNumber = 0;
  }

  private void resetCollections() {
    districts = new ArrayList<District>();
    districtAtPosition = new HashMap<GridPosition, Integer>();
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

  private void assignDistricts() {
    for (Agent agent : agents) {
      int district = districtAtPosition.getOrDefault(agent.getGridPosition(), 0);
      agent.setHomeDistrict(district);
      agent.setCurrentDistrict(district);
    }
    for (Monument monument : monuments.values()) {
      int district = districtAtPosition.getOrDefault(monument.getPosition(), 0);
      monument.setDistrict(district);
    }
  }

  private void beginGame() {
    paused = false;
    storeOriginalAgents();
    storeOriginalMonuments();
    originalGridOccupancy = gridOccupancy.clone();
    createAgents();
    createMonuments();
    assignDistricts();
    dataLogger.init();
    dataLogger.logConfig(config);
    resetCounters();
    savedJSON = false;
    stage = GameStage.START;
  }

  private void resetCounters() {
    framesToMove = MOVE_FRAMES;
    framesForClustering = SHOW_CLUSTERING_FRAMES;
    framesForVotes = SHOW_VOTES_FRAMES;
    movementRounds = config.getNumMoves();
    roundsRemaining = config.getNumRounds();
  }

  private void resetGridOccupancy() {
    int gridSize = config.getGridSize();
    gridOccupancy = new int[gridSize*gridSize];
  }
  
  private void createNewGridOccupancy() {
    int gridSize = config.getGridSize();
    gridOccupancy = new int[gridSize*gridSize];
    originalGridOccupancy = new int[gridSize*gridSize];
  }

  public boolean tryAddAgent(GridPosition position) {
    if (gridOccupancy[positionToIndex(position)] == config.getMaxGridOccupancy() || agents.size() == config.getNumAgents()) {
      return false;
    }
    incrementGridOccupancy(position);
    int positionInBox = gridOccupancyAtPosition(position);
    Agent agent = new Agent(nextAgentID++, position, positionInBox);    
    //Agent agent = new MonumentViewingAgent(nextAgentID++, position, positionInBox);  
    //Agent agent = new MonumentEditingAgent(nextAgentID++, position, positionInBox);
    //Agent agent = new SmarterAgent(nextAgentID++, position, positionInBox); //Let's see how this lot does!!
    //Agent agent = new HomelyAgent(nextAgentID++, position, positionInBox); //Let's see how this lot does!!
    //Agent agent = new TalkativeAgent(nextAgentID++, position, positionInBox);
    //Agent agent = new RememberingAgent(nextAgentID++, position, positionInBox);
    //Agent agent = new SocialAgent(nextAgentID++, position, positionInBox);
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
    Monument monument = new Monument(position, "", config.getMonumentVisibility());
    //Monument monument = new CirclingMonument(position, "", config.getMonumentVisibility());
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

  private void populateDistrictPositionMap(District district) {
    for (int x = district.getTopLeft().getX(); x <= district.getBottomRight().getX(); x++) {
      for (int y = district.getTopLeft().getY(); y <= district.getBottomRight().getY(); y++) {
        districtAtPosition.put(new GridPosition(x, y), nextDistrictNumber);
      }
    }
    nextDistrictNumber++;
  }

  private boolean districtsOverlap(District d1, District d2) {
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
    populateDistrictPositionMap(newDistrict);
    return true;
  }

  public boolean containsDistricts() {
    return districts.size() > 0;
  }
  
  public int numDistricts() {
    return districts.size();
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
    nextDistrictNumber = 0;
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
    int numClusters = config.getNumClusters();
    HashMap<Integer, Integer> votes = new HashMap<Integer, Integer>();
    gatherVotes(votes);
    boolean[] clusterResults = new boolean[numClusters];
    voteResults = subgameHandler.computeResults(numClusters, config.getNumChoices(), agents, votes, clusterResults);
    distributeVoteResults();
    handleMonumentEditing(); //Agents can update monuments after receiving game results
    ArrayList<Integer> winningClusterSizes = dataLogger.logRound(agents, votes, voteResults, numClusters);
    visInfoPanel.addWinningClusterSizes(winningClusterSizes);
    if (!config.getLocalisedMonuments() && config.getNumMonuments() > 0) {
      visInfoPanel.updateWinRateByMonumentProximity(clusterResults, clusterDistancesToMonuments);
    }
  }

  public boolean getAgentResult(int ID) {
    return voteResults.get(ID);
  }

  private ArrayList<Monument> monumentsVisibleForAgent(Agent agent) {
    ArrayList<Monument> visibleMonuments = new ArrayList<Monument>();
    for (Monument monument : monuments.values()) {
      if (monument.canBeSeen(agent.getGridPosition())) {
        if (!config.getLocalisedMonuments() || (monument.getDistrict() == agent.getCurrentDistrict())) {
          visibleMonuments.add(monument);
        }
      }
    }
    return visibleMonuments;
  }

  private void handleMonumentViewing() {
    if (config.getNumMonuments() == 0) {
      return;
    }
    for (Agent agent : agents) {
      agent.viewMonuments(monumentsVisibleForAgent(agent));
    }
  }

  private void handleMonumentEditing() {
    if (config.getNumMonuments() == 0) {
      return;
    }
    for (Agent agent : agents) {
      GridPosition agentPosition = agent.getGridPosition();
      if (monuments.containsKey(agentPosition)) {
        agent.editMonument(monuments.get(agentPosition));
      }
    }
  }

  private FractionalGridPosition[] calculateClusterMeans(int[] agentsPerCluster) {
    int numClusters = config.getNumClusters();
    int[] xSums = new int[numClusters];
    int[] ySums = new int[numClusters];
    for (Agent agent : agents) {
      GridPosition position = agent.getGridPosition();
      int cluster = agent.getClusterNumber();
      xSums[cluster] += position.getX();
      ySums[cluster] += position.getY();
    }
    FractionalGridPosition[] means = new FractionalGridPosition[numClusters];
    for (int index = 0; index < numClusters; index++) {
      float xMean = (float)xSums[index]/agentsPerCluster[index]; // Potentially dividing by zero???
      float yMean = (float)ySums[index]/agentsPerCluster[index];
      means[index] = new FractionalGridPosition(xMean, yMean);
    }
    return means;
  }
  
  private void findNearestMonuments(FractionalGridPosition[] means) {
    int numClusters = config.getNumClusters();
    clusterDistancesToMonuments = new float[numClusters];
    for (int index = 0; index < numClusters; index++) {
      FractionalGridPosition position = means[index];
      float shortestDistance = 1000; // some large number
      for (Monument monument : monuments.values()) {
        float distance = position.distanceTo(monument.getPosition());
        if (distance < shortestDistance) {
          shortestDistance = distance;
        }
      }
      clusterDistancesToMonuments[index] = shortestDistance;
    }
  }
  
  private void setCentroidPositions(FractionalGridPosition[] centroidPositions) {
    this.centroidPositions = centroidPositions;
  }

  private ArrayList<Integer> districtsOfPositions(ArrayList<GridPosition> positions) {
    ArrayList<Integer> districtsArray = new ArrayList<Integer>();
    if (nextDistrictNumber != 0) {
      for (GridPosition position : positions) {
        districtsArray.add(districtAtPosition.get(position));
      }
    } else {
      for (int i = 0; i < positions.size(); i++) {
        districtsArray.add(0);
      }
    }
    return districtsArray;
  }
  
  private int[] districtClustering() {
    int[] agentsPerCluster = new int[districts.size()];
    for (Agent agent : agents) {
      int clusterNumber = agent.getCurrentDistrict();
      agent.setClusterNumber(clusterNumber);
      agentsPerCluster[clusterNumber]++;
    }
    return agentsPerCluster;
  }
  
  private ArrayList<GridPosition> getValidMonumentPositions(GridPosition position, Set<GridPosition> occupiedPositions) {
    ArrayList<GridPosition> validPositions = new ArrayList<GridPosition>();
    validPositions.add(position); //Current position is valid

    int x = position.getX();
    int y = position.getY();

    if (x > 0 && !occupiedPositions.contains(new GridPosition(x-1, y))) {
      validPositions.add(new GridPosition(x-1, y));
    }
    if (x < config.getGridSize() - 1 && !occupiedPositions.contains(new GridPosition(x+1, y))) {
      validPositions.add(new GridPosition(x+1, y));
    }
    if (y > 0 && !occupiedPositions.contains(new GridPosition(x, y-1))) {
      validPositions.add(new GridPosition(x, y-1));
    }
    if (y < config.getGridSize() - 1 && !occupiedPositions.contains(new GridPosition(x, y+1))) {
      validPositions.add(new GridPosition(x, y+1));
    }
    return validPositions;
  }
  
  private void handleCommunicating() {
    HashMap<GridPosition, ArrayList<Agent>> agentGroups = new HashMap<GridPosition, ArrayList<Agent>>();
    for (Agent agent : agents) {
      GridPosition position = agent.getGridPosition();
      if (agentGroups.containsKey(position)) {
        ArrayList<Agent> agentList = agentGroups.get(position);
        agentList.add(agent);
      } else {
        ArrayList<Agent> agentList = new ArrayList<Agent>();
        agentList.add(agent);
        agentGroups.put(position, agentList);
      }
    }
    for (Agent agent : agents) {
      GridPosition position = agent.getGridPosition();
      ArrayList<Agent> agentList = agentGroups.get(position);
      if (agentList.size() > 1) {
        agent.communicate(agentList);
      }
    }
  }

  private void startStage() {
    roundsRemaining--;
    stage = GameStage.MOVE_DECISION;
  }

  private void moveDecisionStage() {
    oldGridOccupancy = gridOccupancy.clone();
    for (Agent agent : agents) {
      GridPosition position = agent.getGridPosition();
      ArrayList<GridPosition> validPositions = getValidPositions(position);
      ArrayList<Integer> districtsArray = districtsOfPositions(validPositions);
      int nextPositionIndex = agent.chooseNextGridPosition(validPositions, districtsArray);
      GridPosition nextPosition = validPositions.get(nextPositionIndex);
      agent.setNextGridPosition(nextPosition);
      agent.setCurrentDistrict(districtAtPosition.getOrDefault(nextPosition, 0));

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
      framesToMove = MOVE_FRAMES;
      stage = GameStage.COMMUNICATION;
      return;
    }
    gameGraphics.update();
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
    handleCommunicating();
  }

  private void clusteringStage() {
    if (framesForClustering == SHOW_CLUSTERING_FRAMES) {
      int[] agentsPerCluster;
      if (config.getDistrictClusters()) {
        agentsPerCluster = districtClustering();
      } else {
        agentsPerCluster = kMeansClustering(config.getNumClusters(), agents);
      }
      if (config.getNumMonuments() > 0 && !config.getLocalisedMonuments()) {
        if (config.getDistrictClusters()) {
          FractionalGridPosition[] means = calculateClusterMeans(agentsPerCluster);
          findNearestMonuments(means);
        } else {
          findNearestMonuments(centroidPositions);
        }
      }
      visInfoPanel.updateClusterCounts(agentsPerCluster);
      gameGraphics.update();
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
      gameGraphics.update();
    }
    framesForVotes--;
    if (framesForVotes == 0) {
      framesForVotes = SHOW_VOTES_FRAMES;
      if (roundsRemaining > 0) {
        if (config.getNumMonuments() > 0) {
          stage = GameStage.MONUMENT_MOVE_DECISION;
        } else {
          stage = GameStage.START;
        }
      } else {
        stage = GameStage.FINISH;
      }
    }
  }
  
  private void monumentMoveDecisionStage() {
    HashSet<GridPosition> occupiedPositions = new HashSet<GridPosition>();
    for (GridPosition position : monuments.keySet()) {
      occupiedPositions.add(position.clone());
    }
    ArrayList<Monument> updatedMonuments = new ArrayList<Monument>();
    for (Monument monument : monuments.values()) {
      GridPosition currentPosition = monument.getPosition();
      ArrayList<GridPosition> validPositions = getValidMonumentPositions(currentPosition, occupiedPositions);
      int positionIndex = monument.chooseNextGridPosition(validPositions);
      GridPosition nextPosition = validPositions.get(positionIndex);
      occupiedPositions.remove(currentPosition);
      occupiedPositions.add(nextPosition);
      monument.setNextPosition(nextPosition);
      updatedMonuments.add(monument);
    }
    monuments.clear();
    for (Monument monument : updatedMonuments) {
      monuments.put(monument.getPosition(), monument);
    }
    stage = GameStage.MONUMENTS_MOVING;
  }
  
  private void monumentsMovingStage() {
    framesToMove--;
    if (framesToMove == 0) {
      for (Monument monument : monuments.values()) {
        monument.reachedNextGridPosition();
      }
      framesToMove = MOVE_FRAMES;
      stage = GameStage.START;
      return;
    }
    gameGraphics.update();
  }

  private void finishStage() {
    if (!savedJSON) {
      visInfoPanel.logFinalStatistics(dataLogger);
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
      gameGraphics.update();
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
    case MONUMENT_MOVE_DECISION:
      monumentMoveDecisionStage();
      break;
    case MONUMENTS_MOVING:
      monumentsMovingStage();
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
