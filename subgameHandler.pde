public enum Subgame {
  CONSENSUS, // All agents need to pick same option - all get reward
  MAJORITY // >50% of agents need to pick same option - all get reward
}

/* To add a new subgame:
 * 1. Add the game to the Enum above
 * 2. Add the string corresponding to the enum value to the SUBGAMES array in FYP
 * 3. Add a method to SubgameHandler, similar to consensusGame, that implements the game
 * 4. Add the game to the switch statement in computeResults (SubgameHandler method)
 */

public class SubgameHandler {
  
  SubgameHandler() {
    
  }
  
  // Returns a map, ID -> result
  public HashMap<Integer, Boolean> computeResults(int numClusters, int numChoices, ArrayList<Agent> agents, HashMap<Integer, Integer> choices) {
    switch (config.getSubgame()) {
      case CONSENSUS:
        return consensusGame(numClusters, agents, choices);
      case MAJORITY:
        return majorityGame(numClusters, numChoices, agents, choices);
      default:
        println("No valid subgame selected");
        return new HashMap<Integer, Boolean>();
    }
  }
  
  private HashMap<Integer, Boolean> consensusGame(int numClusters, ArrayList<Agent> agents, HashMap<Integer, Integer> choices) {
    ArrayList<HashSet<Integer>> votes = new ArrayList<HashSet<Integer>>();
    
    for (int cluster = 0; cluster < numClusters; cluster++) {
      HashSet<Integer> set = new HashSet<Integer>();
      votes.add(set);
    }
    
    for (Agent agent : agents) {
      int cluster = agent.getClusterNumber();
      int choice = choices.get(agent.getID());
      votes.get(cluster).add(choice);
    }
    
    boolean[] clusterResults = new boolean[numClusters];
    
    for (int cluster = 0; cluster < numClusters; cluster++) {
      clusterResults[cluster] = votes.get(cluster).size() == 1;
    }
    
    HashMap<Integer, Boolean> result = new HashMap<Integer, Boolean>();
    
    for (Agent agent : agents) {
      result.put(agent.getID(), clusterResults[agent.getClusterNumber()]);
    }
    
    return result;
  }
  
  private HashMap<Integer, Boolean> majorityGame(int numClusters, int numChoices, ArrayList<Agent> agents, HashMap<Integer, Integer> choices) {
    int[][] votes = new int[numClusters][numChoices];
    
    for (Agent agent : agents) {
      int cluster = agent.getClusterNumber();
      int choice = choices.get(agent.getID()) - 1;
      votes[cluster][choice]++;
    }
    
    boolean[] clusterResults = new boolean[numClusters];
    
    for (int cluster = 0; cluster < numClusters; cluster++) {
      int numAgents = 0;
      int maxChoice = 0;
      for (int choice = 0; choice < numChoices; choice++) {
        numAgents += votes[cluster][choice];
        maxChoice = max(maxChoice, votes[cluster][choice]);
      }
      clusterResults[cluster] = (float(maxChoice) / float(numAgents)) > 0.5; 
    }
    
    HashMap<Integer, Boolean> result = new HashMap<Integer, Boolean>();
    
    for (Agent agent : agents) {
      result.put(agent.getID(), clusterResults[agent.getClusterNumber()]);
    }
    
    return result;
  }
}
