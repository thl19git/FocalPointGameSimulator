public class SmarterAgent extends Agent {
  private String mostRecentTextSeen;

  SmarterAgent(int ID, GridPosition gridPosition, int positionInBox) {
    super(ID, gridPosition, positionInBox);

    mostRecentTextSeen = "";
  }

  @Override
  public void viewMonuments(ArrayList<Monument> monuments) {
    if (monuments.size() == 0) {
      return;
    }

    String monumentText = "";
    if (monuments.size() == 1) {
      Monument monument = monuments.get(0);
      monumentText = monument.getText();
    } else {
      float closestDistance = 1000; // just a big number
      for (Monument monument : monuments) {
        float distance = gridPosition.distanceTo(monument.getPosition());
        if (distance < closestDistance) {
          closestDistance = distance;
          monumentText = monument.getText();
        }
      }
    }
    mostRecentTextSeen = monumentText;
  }

  @Override
  public int voteForChoice(int numChoices, ArrayList<Monument> visibleMonuments) {
    viewMonuments(visibleMonuments);

    if (mostRecentTextSeen.equals("Hi")) {
      return numChoices;
    } else if (mostRecentTextSeen.equals("Lo")) {
      return 1;
    }
    int choice = ceil(random(numChoices));
    return choice;
  }
}
