public class Agent {
  protected final int ID;
  protected GridPosition gridPosition;
  protected int homeDistrict;
  protected int currentDistrict;
  private GridPosition nextGridPosition;
  protected int positionInBox;
  private int nextPositionInBox;
  protected int clusterNumber;

  Agent(int ID, GridPosition gridPosition, int positionInBox) {
    this.ID = ID;
    this.gridPosition = gridPosition;
    this.nextGridPosition = gridPosition;
    this.positionInBox = positionInBox;
    this.nextPositionInBox = positionInBox;
    this.clusterNumber = 0;
    this.homeDistrict = 0;
    this.currentDistrict = 0;
  }

  public int getID() {
    return ID;
  }

  public GridPosition getGridPosition() {
    return gridPosition;
  }

  public void setGridPosition(GridPosition gridPosition) {
    this.gridPosition = gridPosition;
  }

  public GridPosition getNextGridPosition() {
    return nextGridPosition;
  }

  public void setNextGridPosition(GridPosition nextGridPosition) {
    this.nextGridPosition = nextGridPosition;
  }

  public int chooseNextGridPosition(final ArrayList<GridPosition> validPositions, final ArrayList<Integer> districts) {
    return floor(random(validPositions.size()));
  }

  public void reachedNextGridPosition() {
    gridPosition = nextGridPosition;
    positionInBox = nextPositionInBox;
  }

  public int getPositionInBox() {
    return positionInBox;
  }

  public void setPositionInBox(int positionInBox) {
    this.positionInBox = positionInBox;
  }

  public int getNextPositionInBox() {
    return nextPositionInBox;
  }

  public void setNextPositionInBox(int nextPositionInBox) {
    this.nextPositionInBox = nextPositionInBox;
  }

  public int getClusterNumber() {
    return clusterNumber;
  }

  public void setClusterNumber(int clusterNumber) {
    this.clusterNumber = clusterNumber;
  }

  public int getHomeDistrict() {
    return homeDistrict;
  }

  public void setHomeDistrict(int homeDistrict) {
    this.homeDistrict = homeDistrict;
  }

  public int getCurrentDistrict() {
    return currentDistrict;
  }

  public void setCurrentDistrict(int currentDistrict) {
    this.currentDistrict = currentDistrict;
  }

  // Must return a number in the range [1..numChoices]
  public int voteForChoice(int numChoices, ArrayList<Monument> visibleMonuments) {
    int choice = ceil(random(numChoices));
    return choice;
  }

  public void receiveVoteResult(boolean result) {
    // Do something
  }

  public void viewMonuments(ArrayList<Monument> monuments) {
    //println("I am in district " + currentDistrict + " and I can see " + monuments.size() + " monuments");
  }

  public void editMonument(Monument monument) {
    // Do something
  }
  
  // Note that otherAgents will also contain a reference to the agent itself
  public void communicate(ArrayList<Agent> otherAgents) {
    // Do something
  }
  
  public void receiveMessage(Agent sender, String message) {
    // Do something
  }

  public Agent clone() {
    return new Agent(ID, gridPosition, positionInBox);
  }
}
