public class Agent {
  private final int ID;
  private GridPosition gridPosition;
  
  Agent(int ID, GridPosition gridPosition) {
    this.ID = ID;
    this.gridPosition = gridPosition;
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
}
