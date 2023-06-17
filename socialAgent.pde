public class SocialAgent extends Agent {

  private HashSet<Integer> agentIDs;
  private LinkedList<Agent> socialNetwork;
  int[] choiceSentiments;
  int lastChoice;
  boolean lastResult;
  int roundsSinceSuccess;
  
  SocialAgent(int ID, GridPosition gridPosition, int positionInBox) {
    super(ID, gridPosition, positionInBox);
    agentIDs = new HashSet<Integer>();
    socialNetwork = new LinkedList<Agent>();
    choiceSentiments = new int[config.getNumChoices()];
    roundsSinceSuccess = 0;
  }
  
  @Override
  public void receiveVoteResult(boolean result) {
    lastResult = result;
    if (result == true) {
      roundsSinceSuccess = 0;
      choiceSentiments[lastChoice - 1] += 5;
    } else {
      choiceSentiments[lastChoice - 1]--;
      roundsSinceSuccess++;
    }
    for (Agent agent : socialNetwork) {
      sendMessage(agent);
    }
  }
  
  @Override
  public int chooseNextGridPosition(final ArrayList<GridPosition> validPositions, final ArrayList<Integer> districts) {
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
    for (Agent agent : otherAgents) {
      if (!agentIDs.contains(agent.getID()) && agent.getID() != ID) {
        // If social network is full, remove oldest agent
        if (socialNetwork.size() == MAX_NETWORK_SIZE) {
          Agent firstAgent = socialNetwork.removeFirst();
          agentIDs.remove(firstAgent.getID());
        }
        socialNetwork.addLast(agent);
        agentIDs.add(agent.getID());
      }
    }
  }
  
  @Override
  public int voteForChoice(int numChoices, ArrayList<Monument> visibleMonuments) {
    if (roundsSinceSuccess == 20) {
      roundsSinceSuccess = 0;
      choiceSentiments = new int[config.getNumChoices()];
    }
    
    ArrayList<Integer> bestChoices = new ArrayList<Integer>();
    int highestSentiment = -10000000; // just a low number
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
    return new SocialAgent(ID, gridPosition, positionInBox);
  }
}
