public class Monument {
  private GridPosition position;
  private GridPosition nextPosition;
  private String text;
  private int district;
  public final float viewDistance;

  Monument(GridPosition position, String text, float viewDistance) {
    setPosition(position);
    setNextPosition(position);
    setText(text);
    this.viewDistance = viewDistance;
    district = 0;
  }

  public GridPosition getPosition() {
    return position;
  }

  public void setPosition(GridPosition position) {
    this.position = position;
  }
  
  public GridPosition getNextPosition() {
    return nextPosition;
  }
  
  public void setNextPosition(GridPosition nextPosition) {
    this.nextPosition = nextPosition;
  }
  
  public void reachedNextGridPosition() {
    position = nextPosition;
  }

  public String getText() {
    return text;
  }

  public void setText(String text) {
    this.text = text;
  }

  public int getDistrict() {
    return district;
  }

  public void setDistrict(int district) {
    this.district = district;
  }
  
  public int chooseNextGridPosition(final ArrayList<GridPosition> validPositions) {
    //return floor(random(validPositions.size()));
    return 0;
  }

  public boolean canBeSeen(GridPosition position) {
    return position.distanceTo(this.position) <= viewDistance;
  }

  public Monument clone() {
    return new Monument(position, text, viewDistance);
  }
}
