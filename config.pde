public class Config {
  private int numAgents;
  private int gridSize;
  private int numRounds;
  private int numClusters;
  private int numChoices;
  private int numMoves;
  private int maxGridOccupancy;
  private Subgame subgame;
  
  Config() {
    setGridSize(10);
    setNumAgents(30);
    setNumRounds(10);
    setMaxGridOccupancy(4);
    setNumClusters(6);
    setNumChoices(4);
    setNumMoves(4);
    setSubgame(Subgame.MAJORITY);
  }

  public int getNumAgents() {
    return numAgents;
  }

  public void setNumAgents(int numAgents) {
    this.numAgents = clamp(1, gridSize*gridSize, numAgents);
  }

  public int getGridSize() {
    return gridSize;
  }

  public void setGridSize(int gridSize) {
    this.gridSize = max(3, gridSize);
  }

  public int getNumRounds() {
    return numRounds;
  }

  public void setNumRounds(int numRounds) {
    this.numRounds = max(1, numRounds);
  }

  public int getNumClusters() {
    return numClusters;
  }

  public void setNumClusters(int numClusters) {
    //this.numClusters = clamp(1, INITIAL_AGENT_COLORS.length, numClusters);
    int maxClusters = ceil(float(numAgents) / float(maxGridOccupancy));
    this.numClusters = clamp(1, min(maxClusters, INITIAL_AGENT_COLORS.length), numClusters);
  }

  public int getNumChoices() {
    return numChoices;
  }

  public void setNumChoices(int numChoices) {
    this.numChoices = max(1, numChoices);
  }
  
  public int getNumMoves() {
    return numMoves;
  }
  
  public void setNumMoves(int numMoves) {
    this.numMoves = max(0, numMoves);
  }
  
  public int getMaxGridOccupancy() {
    return maxGridOccupancy;
  }
  
  public void setMaxGridOccupancy(int maxGridOccupancy) {
    this.maxGridOccupancy = clamp(1, 4, maxGridOccupancy);
  }
  
  public Subgame getSubgame() {
    return subgame;
  }
  
  public void setSubgame(Subgame subgame) {
    this.subgame = subgame;
  }
}
