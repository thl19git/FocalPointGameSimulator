public class GridPosition implements Comparable<GridPosition>{
  private int x;
  private int y;
  
  GridPosition(int xCoord, int yCoord) {
    setPosition(xCoord, yCoord);
  }
  
  public void setPosition(int xCoord, int yCoord) {
    setX(xCoord);
    setY(yCoord);
  }
  
  public void setX(int xCoord) {
    x = clamp(0, config.getGridSize(), xCoord);
  }
  
  public void setY(int yCoord) {
    y = clamp(0, config.getGridSize(), yCoord);
  }
  
  public int getX() {
    return x;
  }
  
  public int getY() {
    return y;
  }
  
  @Override
  public int compareTo(GridPosition position) {
    if (position.getY() == this.y) {
      if (position.getX() == this.x) {
        return 0;
      } else if (position.getX() > this.x) {
        return -1;
      } else {
        return 1;
      }
    } else if (position.getY() > this.y) {
      return -1;
    } else {
      return 1;
    }
  }
}
