public class Monument {
  protected GridPosition position;
  private GridPosition nextPosition;
  protected String text;
  protected int district;
  public final float viewDistance;

  Monument(GridPosition position, String text, float viewDistance) {
    setPosition(position);
    setNextPosition(position);
    setText(text);
    this.viewDistance = viewDistance;
    district = 0;
  }

  public final GridPosition getPosition() {
    return position;
  }

  public final void setPosition(GridPosition position) {
    this.position = position;
  }
  
  public final GridPosition getNextPosition() {
    return nextPosition;
  }
  
  public final void setNextPosition(GridPosition nextPosition) {
    this.nextPosition = nextPosition;
  }
  
  public final void reachedNextGridPosition() {
    position = nextPosition;
  }

  public final String getText() {
    return text;
  }

  public final void setText(String text) {
    this.text = text;
  }

  public final int getDistrict() {
    return district;
  }

  public final void setDistrict(int district) {
    this.district = district;
  }
  
  public int chooseNextGridPosition(final ArrayList<GridPosition> validPositions) {
    //return floor(random(validPositions.size()));
    return 0;
  }

  public final boolean canBeSeen(GridPosition position) {
    return position.distanceTo(this.position) <= viewDistance;
  }

  public Monument clone() {
    return new Monument(position, text, viewDistance);
  }
}
