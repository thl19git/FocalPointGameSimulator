public class Agent {
  private final int ID;
  private GridPosition gridPosition;
  private GridPosition nextGridPosition;
  private int positionInBox;
  private int nextPositionInBox;
  
  Agent(int ID, GridPosition gridPosition, int positionInBox) {
    this.ID = ID;
    this.gridPosition = gridPosition;
    this.nextGridPosition = gridPosition;
    this.positionInBox = positionInBox;
    this.nextPositionInBox = positionInBox;
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
  
  public int chooseNextGridPosition(final ArrayList<GridPosition> validPositions) {
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
}
