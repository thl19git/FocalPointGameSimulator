public class DataLogger {
  private int roundNumber;
  private JSONObject data;
  private JSONObject round;
  private JSONArray rounds;
  private String logName;

  DataLogger() {
    init();
  }

  public void init() {
    roundNumber = 0;
    data = new JSONObject();
    rounds = new JSONArray();
    logName = "logs/log-" + str(day()) + "-" + str(month()) + "-" + str(year()) + "-" + str(hour()) + "-" + str(minute()) + "-" + str(second()) + ".json";
  }

  public void logConfig(Config conf) {
    data.setInt("gridSize", conf.getGridSize());
    data.setInt("numAgents", conf.getNumAgents());
    data.setInt("numRounds", conf.getNumRounds());
    data.setInt("numClusters", conf.getNumClusters());
    data.setInt("numChoices", conf.getNumChoices());
    data.setInt("numMoves", conf.getNumMoves());
    data.setInt("maxOccupancy", conf.getMaxGridOccupancy());
    data.setInt("numMonuments", conf.getNumMonuments());
    data.setFloat("monumentVisibility", conf.getMonumentVisibility());
    data.setBoolean("localisedMonuments", conf.getLocalisedMonuments());
    data.setBoolean("districtClusters", conf.getDistrictClusters());
    data.setString("subgame", conf.getSubgame().name());
  }

  public ArrayList<Integer> logRound(ArrayList<Agent> agents, HashMap<Integer, Integer> votes, HashMap<Integer, Boolean> results, int numClusters) {
    roundNumber++;
    round = new JSONObject();
    round.setInt("number", roundNumber);

    JSONArray clusters = new JSONArray();

    for (int cluster = 0; cluster < numClusters; cluster++) {
      JSONObject agentsObject = new JSONObject();
      agentsObject.setJSONArray("agents", new JSONArray());
      clusters.setJSONObject(cluster, agentsObject);
    }

    for (Agent agent : agents) {
      int ID = agent.getID();
      int choice = votes.get(ID);
      boolean result = results.get(ID);

      int cluster = agent.getClusterNumber();
      JSONObject agentsObject = clusters.getJSONObject(cluster);
      JSONArray agentsArray = agentsObject.getJSONArray("agents");
      JSONObject newAgentObject = new JSONObject();
      newAgentObject.setInt("id", ID);
      newAgentObject.setInt("choice", choice);
      newAgentObject.setBoolean("result", result);
      agentsArray.append(newAgentObject);
    }

    round.setJSONArray("clusters", clusters);
    rounds.append(round);
    
    // Create an array with the sizes of winning clusters
    ArrayList<Integer> winningSizes = new ArrayList<Integer>();
    
    for (int cluster = 0; cluster < numClusters; cluster++) {
      JSONObject agentsObject = clusters.getJSONObject(cluster);
      JSONArray agentsArray = agentsObject.getJSONArray("agents");
      if (agentsArray.size() > 0 && agentsArray.getJSONObject(0).getBoolean("result")) {
        winningSizes.add(agentsArray.size());
      }
    }
    
    return winningSizes;
  }

  public void saveJSON() {
    data.setJSONArray("rounds", rounds);
    saveJSONObject(data, logName);
  }
}
