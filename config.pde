public class Config {
  private int numAgents;
  private int gridSize;
  private int numRounds;
  private int numClusters;
  private int numChoices;
  private int numMoves;
  
  Config() {
    setGridSize(10);
    setNumAgents(50);
    setNumRounds(10);
    setNumClusters(2);
    setNumChoices(5);
    setNumMoves(4);
  }

  public int getNumAgents() {
    return numAgents;
  }

  public void setNumAgents(int numAgents) {
    this.numAgents = clamp(1, gridSize*gridSize/2, numAgents);
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
    this.numClusters = clamp(1, numAgents, numClusters);
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
}
