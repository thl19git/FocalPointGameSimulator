public class District {
  private GridPosition topLeft;
  private GridPosition bottomRight;
  
  District(GridPosition topLeft, GridPosition bottomRight) {
    this.topLeft = topLeft;
    this.bottomRight = bottomRight;
  }
  
  public GridPosition getTopLeft() {
    return topLeft;
  }
  
  public GridPosition getBottomRight() {
    return bottomRight;
  }
  
  public int numSquares() {
    return (bottomRight.getX() - topLeft.getX() + 1) * (bottomRight.getY() - topLeft.getY() + 1);
  }
  
  @Override
  public String toString() {
    return "TL: " + topLeft + ", BR: " + bottomRight;
  }
}
