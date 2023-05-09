public class Config {
  private int numAgents;
  private int gridSize;
  private int numRounds;
  private int numClusters;
  private int numChoices;
  private int numMoves;
  private int maxGridOccupancy;
  private int numMonuments;
  private Subgame subgame;
  
  Config(int newGridSize, int newNumAgents, int newNumRounds, int newGridOccupancy, int newNumClusters, int newNumChoices, int newNumMoves, int newNumMonuments, Subgame newSubgame) {
    setGridSize(newGridSize);
    setNumAgents(newNumAgents);
    setNumRounds(newNumRounds);
    setMaxGridOccupancy(newGridOccupancy);
    setNumClusters(newNumClusters);
    setNumChoices(newNumChoices);
    setNumMoves(newNumMoves);
    setNumMonuments(newNumMonuments);
    setSubgame(newSubgame);
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
    int minOccupancy = ceil(this.numAgents * 2 / float(this.gridSize * this.gridSize));
    this.maxGridOccupancy = clamp(minOccupancy, 4, maxGridOccupancy);
  }
  
  public int getNumMonuments() {
    return numMonuments;
  }
  
  public void setNumMonuments(int numMonuments) {
    int maxMonuments = this.gridSize * this.gridSize / 2;
    this.numMonuments = clamp(0, numMonuments, maxMonuments);
  }
  
  public Subgame getSubgame() {
    return subgame;
  }
  
  public void setSubgame(Subgame subgame) {
    this.subgame = subgame;
  }
}
