public int clamp(int low, int high, int value) {
  return min(high, max(value, low));
}

public float clamp(float low, float high, float value) {
  return min(high, max(value, low));
}

public GridPosition randomGridPosition() {
  int gridSize = config.getGridSize();
  int randomIndex = floor(random(gridSize*gridSize));
  return indexToPosition(randomIndex);
}

public int positionToIndex(GridPosition position) {
  int x = position.getX();
  int y = position.getY();
  int index = x + config.getGridSize() * y;
  
  return index;
}
  
public GridPosition indexToPosition(int index) {
  int gridSize = config.getGridSize();
  return new GridPosition(index % gridSize, index / gridSize);
}
