public class Config {
  private int numAgents;
  private int gridSize;
  private int numRounds;
  private int numClusters;
  private int numChoices;
  
  Config() {
    setGridSize(10);
    setNumAgents(20);
    setNumRounds(10);
    setNumClusters(2);
    setNumChoices(5);
  }

  public int getNumAgents() {
    return numAgents;
  }

  public void setNumAgents(int newNumAgents) {
    numAgents = clamp(1, gridSize*gridSize/2, newNumAgents);
  }

  public int getGridSize() {
    return gridSize;
  }

  public void setGridSize(int newGridSize) {
    gridSize = max(3, newGridSize);
  }

  public int getNumRounds() {
    return numRounds;
  }

  public void setNumRounds(int newNumRounds) {
    numRounds = max(1, newNumRounds);
  }

  public int getNumClusters() {
    return numClusters;
  }

  public void setNumClusters(int newNumClusters) {
    numClusters = clamp(1, numAgents, newNumClusters);
  }

  public int getNumChoices() {
    return numChoices;
  }

  public void setNumChoices(int newNumChoices) {
    numChoices = max(1, newNumChoices);
  }
}
