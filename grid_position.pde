public class GridPosition implements Comparable<GridPosition> {
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

  public float distanceTo(GridPosition position) {
    int diffX = abs(this.x - position.getX());
    int diffY = abs(this.y - position.getY());

    return sqrt(diffX*diffX + diffY*diffY);
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

  @Override
  public boolean equals(Object o) {
    if (o == this)
      return true;
    if (!(o instanceof GridPosition))
      return false;
    GridPosition other = (GridPosition) o;
    return this.x == other.getX() && this.y== other.getY();
  }

  @Override
  public int hashCode() {
    return Objects.hash(this.x, this.y);
  }

  @Override
  public String toString() {
    return "(" + x + "," + y + ")";
  }
}
