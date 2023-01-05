public class GridPosition {
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
}
