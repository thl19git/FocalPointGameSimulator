public class Agent {
  private final int ID;
  private GridPosition gridPosition;
  private GridPosition nextGridPosition;
  
  Agent(int ID, GridPosition gridPosition) {
    this.ID = ID;
    this.gridPosition = gridPosition;
    this.nextGridPosition = gridPosition;
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
  }
}
