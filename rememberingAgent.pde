public class RememberingAgent extends Agent {

  int[] choiceSentiments;
  int lastChoice;
  
  RememberingAgent(int ID, GridPosition gridPosition, int positionInBox) {
    super(ID, gridPosition, positionInBox);
    choiceSentiments = new int[config.getNumChoices()];
  }
  
  @Override
  public void receiveVoteResult(boolean result) {
    if (result == true) {
      choiceSentiments[lastChoice - 1] += 5;
    } else {
      choiceSentiments[lastChoice - 1]--;
    }
  }
  
  @Override
  public int chooseNextGridPosition(final ArrayList<GridPosition> validPositions, final ArrayList<Integer> districts) {
    return floor(random(validPositions.size()));
  }
  
  @Override
  public int voteForChoice(int numChoices, ArrayList<Monument> visibleMonuments) {
    ArrayList<Integer> bestChoices = new ArrayList<Integer>();
    int highestSentiment = -1000; // just a low number
    for (int i = 0; i < choiceSentiments.length; i++) {
      if (choiceSentiments[i] > highestSentiment) {
        bestChoices.clear();
        bestChoices.add(i);
        highestSentiment = choiceSentiments[i];
      } else if (choiceSentiments[i] == highestSentiment) {
        bestChoices.add(i);
      }
    }
    int choice = bestChoices.get(floor(random(bestChoices.size()))) + 1;
    lastChoice = choice;
    return choice;
  }
  
  @Override
  public Agent clone() {
    return new RememberingAgent(ID, gridPosition, positionInBox);
  }
}
