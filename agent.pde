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

  public final int getID() {
    return ID;
  }

  public final GridPosition getGridPosition() {
    return gridPosition;
  }

  public final void setGridPosition(GridPosition gridPosition) {
    this.gridPosition = gridPosition;
  }

  public final GridPosition getNextGridPosition() {
    return nextGridPosition;
  }

  public final void setNextGridPosition(GridPosition nextGridPosition) {
    this.nextGridPosition = nextGridPosition;
  }

  public int chooseNextGridPosition(final ArrayList<GridPosition> validPositions, final ArrayList<Integer> districts) {
    return floor(random(validPositions.size()));
  }

  public final void reachedNextGridPosition() {
    gridPosition = nextGridPosition;
    positionInBox = nextPositionInBox;
  }

  public final int getPositionInBox() {
    return positionInBox;
  }

  public final void setPositionInBox(int positionInBox) {
    this.positionInBox = positionInBox;
  }

  public final int getNextPositionInBox() {
    return nextPositionInBox;
  }

  public final void setNextPositionInBox(int nextPositionInBox) {
    this.nextPositionInBox = nextPositionInBox;
  }

  public final int getClusterNumber() {
    return clusterNumber;
  }

  public final void setClusterNumber(int clusterNumber) {
    this.clusterNumber = clusterNumber;
  }

  public final int getHomeDistrict() {
    return homeDistrict;
  }

  public final void setHomeDistrict(int homeDistrict) {
    this.homeDistrict = homeDistrict;
  }

  public final int getCurrentDistrict() {
    return currentDistrict;
  }

  public final void setCurrentDistrict(int currentDistrict) {
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
