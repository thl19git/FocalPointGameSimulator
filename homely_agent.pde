public class HomelyAgent extends Agent {

  HomelyAgent(int ID, GridPosition gridPosition, int positionInBox) {
    super(ID, gridPosition, positionInBox);
  }

  @Override
  public int chooseNextGridPosition(final ArrayList<GridPosition> validPositions, final ArrayList<Integer> districts) {
    ArrayList<Integer> sameDistrictPositions = new ArrayList<Integer>();
    ArrayList<Integer> differentDistrictPositions = new ArrayList<Integer>();
    for (int index = 0; index < districts.size(); index++) {
      if (districts.get(index) == homeDistrict) {
        sameDistrictPositions.add(index);
      } else {
        differentDistrictPositions.add(index);
      }
    }
    if ((differentDistrictPositions.size() > 0 && ceil(random(10)) == 1) || sameDistrictPositions.size() == 0) { // 10% chance of changing district
      return differentDistrictPositions.get(floor(random(differentDistrictPositions.size())));
    } else {
      return sameDistrictPositions.get(floor(random(sameDistrictPositions.size())));
    }
  }
}
