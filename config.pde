public class Config {
  private int numAgents;
  private int gridSize;
  private int numRounds;
  private int numClusters;
  private int numChoices;
  private int numMoves;
  private int maxGridOccupancy;
  private int numMonuments;
  private float monumentVisibility;
  private boolean localisedMonuments;
  private boolean districtClusters;
  private Subgame subgame;

  Config(int gridSize, int numAgents, int numRounds, int gridOccupancy, int numClusters, int numChoices, int numMoves, int numMonuments, float monumentVisibility, boolean localisedMonuments, boolean districtClusters, Subgame subgame) {
    setGridSize(gridSize);
    setNumAgents(numAgents);
    setNumRounds(numRounds);
    setMaxGridOccupancy(gridOccupancy);
    setDistrictClusters(districtClusters);
    setNumClusters(numClusters);
    setNumChoices(numChoices);
    setNumMoves(numMoves);
    setNumMonuments(numMonuments);
    setMonumentVisibility(monumentVisibility);
    setLocalisedMonuments(localisedMonuments);
    setSubgame(subgame);
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
    int maxClusters;
    if (districtClusters) {
      this.numClusters = clamp(1, 100, numClusters);
    } else {
      maxClusters = ceil(float(numAgents) / float(maxGridOccupancy));
      this.numClusters = clamp(1, min(maxClusters, INITIAL_AGENT_COLORS.length), numClusters);
    }
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

  public float getMonumentVisibility() {
    return monumentVisibility;
  }

  public void setMonumentVisibility(float monumentVisibility) {
    float maxVisibility = float(this.gridSize) * sqrt(2);
    this.monumentVisibility = clamp(0, monumentVisibility, maxVisibility);
  }
  
  public boolean getLocalisedMonuments() {
    return localisedMonuments;
  }
  
  public void setLocalisedMonuments(boolean localisedMonuments) {
    this.localisedMonuments = localisedMonuments;
  }
  
  public boolean getDistrictClusters() {
    return districtClusters;
  }
  
  public void setDistrictClusters(boolean districtClusters) {
    this.districtClusters = districtClusters;
  }

  public Subgame getSubgame() {
    return subgame;
  }

  public void setSubgame(Subgame subgame) {
    this.subgame = subgame;
  }
}
