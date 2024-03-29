public class HomelyAgent extends Agent {
  private String mostRecentTextSeen;
  private boolean mostRecentResult;
  private String mostRecentChoice;
  private String mostRecentEvent;

  HomelyAgent(int ID, GridPosition gridPosition, int positionInBox) {
    super(ID, gridPosition, positionInBox);

    mostRecentTextSeen = "";
    mostRecentResult = false;
    mostRecentChoice = "";
    mostRecentEvent = "result";
  }

  @Override
  public void receiveVoteResult(boolean result) {
    mostRecentResult = result;
    mostRecentEvent = "result";
  }
  
  @Override
  public void editMonument(Monument monument) {
    if (mostRecentEvent.equals("result") && mostRecentResult && (mostRecentChoice.equals("Hi") || mostRecentChoice.equals("Lo"))) {
      monument.setText(mostRecentChoice);
    } else if (!mostRecentTextSeen.equals("")) {
      monument.setText(mostRecentTextSeen);
    } else {
      if (ceil(random(2)) == 2) {
        monument.setText("Hi");
      } else {
        monument.setText("Lo");
      }
    }
  }

  @Override
  public void viewMonuments(ArrayList<Monument> monuments) {
    if (monuments.size() == 0) {
      return;
    }

    String monumentText = String.valueOf(mostRecentTextSeen);
    float closestDistance = 1000; // just a big number
    for (Monument monument : monuments) {
      float distance = gridPosition.distanceTo(monument.getPosition());
      if (distance < closestDistance && !monument.getText().equals("")) {
        closestDistance = distance;
        monumentText = monument.getText();
        mostRecentEvent = "view";
      }
    }
    mostRecentTextSeen = String.valueOf(monumentText);
  }

  @Override
  public int voteForChoice(int numChoices, ArrayList<Monument> visibleMonuments) {
    viewMonuments(visibleMonuments);

    if (mostRecentEvent.equals("result") && mostRecentResult && (mostRecentChoice.equals("Hi") || mostRecentChoice.equals("Lo"))) {
      if (mostRecentChoice.equals("Hi")) {
        return numChoices;
      } else {
        return 1;
      }
    } else if (!mostRecentTextSeen.equals("")) {
      if (mostRecentTextSeen.equals("Hi")) {
        mostRecentChoice = "Hi";
        return numChoices;
      } else {
        mostRecentChoice = "Lo";
        return 1;
      }
    } else {
      int choice = ceil(random(numChoices));
      mostRecentChoice = "Rand";
      return choice;
    }
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
  
  @Override
  public Agent clone() {
    return new HomelyAgent(ID, gridPosition, positionInBox);
  }
}
