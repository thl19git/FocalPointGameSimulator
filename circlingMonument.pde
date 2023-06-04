public class CirclingMonument extends Monument {

  CirclingMonument(GridPosition position, String text, float viewDistance) {
    super(position, text, viewDistance);
    
  }

  @Override
  public int chooseNextGridPosition(final ArrayList<GridPosition> validPositions) {
    int x = position.getX();
    int y = position.getY();
    int g = config.getGridSize();
    
    int nextX = x;
    int nextY = y;
    
    if (y == 1) {
      if (x == g - 2) {
        nextY++;
      } else {
        nextX++;
      }
    } else if (y == g - 2) {
      if (x == 1) {
        nextY--;
      } else {
        nextX--;
      }
    } else if (x == 1) {
      if (y == 1) {
        nextX++;
      } else {
        nextY--;
      }
    } else {
      if (y == g - 2) {
        nextX--;
      } else {
        nextY++;
      }
    }
    
    for (int index = 0; index < validPositions.size(); index++) {
      GridPosition p = validPositions.get(index);
      if (nextX == p.getX() && nextY == p.getY()) {
        return index;
      }
    }
    
    return floor(random(validPositions.size()));
  }

  public Monument clone() {
    return new CirclingMonument(position, text, viewDistance);
  }
}
