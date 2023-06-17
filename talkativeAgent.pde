public class TalkativeAgent extends Agent {

  private HashSet<Integer> agentIDs;
  int[] choiceSentiments;
  int lastChoice;
  boolean lastResult;
  boolean played;
  
  TalkativeAgent(int ID, GridPosition gridPosition, int positionInBox) {
    super(ID, gridPosition, positionInBox);
    agentIDs = new HashSet<Integer>();
    choiceSentiments = new int[config.getNumChoices()];
    played = false;
  }
  
  @Override
  public void receiveVoteResult(boolean result) {
    lastResult = result;
    if (result == true) {
      choiceSentiments[lastChoice - 1] += 5;
    } else {
      choiceSentiments[lastChoice - 1]--;
    }
    played = true;
  }
  
  @Override
  public int chooseNextGridPosition(final ArrayList<GridPosition> validPositions, final ArrayList<Integer> districts) {
    agentIDs.clear();
    agentIDs.add(ID);
    return floor(random(validPositions.size()));
  }
  
  @Override
  public void receiveMessage(Agent sender, String message) {
    String[] parts = message.split(",");
    String result = parts[0];
    String choice = parts[1];
    
    if (result.equals("win")) {
      choiceSentiments[int(choice) - 1] += 5;
    } else {
      choiceSentiments[int(choice) - 1]--;
    }
    
    if (!agentIDs.contains(sender.getID())) {
      agentIDs.add(sender.getID());
      sendMessage(sender);
    }
  }
  
  private void sendMessage(Agent agent) {
    String message = "";
    if (lastResult == true) {
      message += "win,";
    } else {
      message += "loss,";
    }
    message += str(lastChoice);
    agent.receiveMessage(this, message);
  }
  
  @Override
  public void communicate(ArrayList<Agent> otherAgents) {
    if (played == false) {
      return;
    }
    for (Agent agent : otherAgents) {
      if (!agentIDs.contains(agent.getID())) {
        sendMessage(agent);
        agentIDs.add(agent.getID());
      }
    }
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
    return new TalkativeAgent(ID, gridPosition, positionInBox);
  }
}
