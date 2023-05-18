public class FractionalGridPosition implements Comparable<FractionalGridPosition> {
  private float x;
  private float y;

  FractionalGridPosition(float xCoord, float yCoord) {
    setPosition(xCoord, yCoord);
  }
  
  FractionalGridPosition(GridPosition position) {
    setPosition(position.getX(), position.getY());
  }

  public void setPosition(float xCoord, float yCoord) {
    setX(xCoord);
    setY(yCoord);
  }

  public void setX(float xCoord) {
    x = clamp(0, config.getGridSize(), xCoord);
  }

  public void setY(float yCoord) {
    y = clamp(0, config.getGridSize(), yCoord);
  }

  public float getX() {
    return x;
  }

  public float getY() {
    return y;
  }

  public float distanceTo(GridPosition position) {
    float diffX = abs(this.x - position.getX());
    float diffY = abs(this.y - position.getY());

    return sqrt(diffX*diffX + diffY*diffY);
  }
  
  public float distanceTo(FractionalGridPosition position) {
    float diffX = abs(this.x - position.getX());
    float diffY = abs(this.y - position.getY());

    return sqrt(diffX*diffX + diffY*diffY);
  }

  @Override
  public int compareTo(FractionalGridPosition position) {
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
