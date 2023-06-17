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
  
  private void logClusterSizeCountsWins(float[] clusterSizeCounts, float[] winsByClusterSize) {
    for (int index = clusterSizeCounts.length - 1; index >= 0; index--) {
      if (clusterSizeCounts[index] == 0) {
        continue;
      }
      
      JSONArray clusterCounts = new JSONArray();
      for (int j_index = 0; j_index <= index; j_index++) {
        JSONObject clusterCountObject = new JSONObject();
        clusterCountObject.setInt("size", j_index);
        clusterCountObject.setInt("frequency", (int)clusterSizeCounts[j_index]);
        clusterCountObject.setInt("wins", (int)winsByClusterSize[j_index]);
        clusterCounts.setJSONObject(j_index, clusterCountObject);
      }
      data.setJSONArray("clusterCounts", clusterCounts);
      break;
    }
  }
  
  private void logMonumentProximityCountsWins(float[] monumentProximityCounts, float[] winsByMonumentProximity) {
    for (int index = monumentProximityCounts.length - 1; index >= 0; index--) {
      if (monumentProximityCounts[index] == 0) {
        continue;
      }
      
      JSONArray proximityCounts = new JSONArray();
      for (int j_index = 0; j_index <= index; j_index++) {
        JSONObject proximityCountObject = new JSONObject();
        proximityCountObject.setString("distance", str(j_index)+" - "+str(j_index+1));
        proximityCountObject.setInt("frequency", (int)monumentProximityCounts[j_index]);
        proximityCountObject.setInt("wins", (int)winsByMonumentProximity[j_index]);
        proximityCounts.setJSONObject(j_index, proximityCountObject);
      }
      data.setJSONArray("monumentProximityCounts", proximityCounts);
      break;
    }
  }
  
  private void logWinRates(ArrayList<PVector> winRatesData) {
    JSONArray winRates = new JSONArray();
    for (int index = 0; index < winRatesData.size(); index++) {
      JSONObject winRateObject = new JSONObject();
      winRateObject.setInt("round", index+1);
      winRateObject.setFloat("winRate", winRatesData.get(index).y);
      winRates.setJSONObject(index, winRateObject);
    }
    data.setJSONArray("winRates", winRates);
  }
  
  public void logFinalStatistics(float[] clusterSizeCounts, float[] winsByClusterSize, float[] monumentProximityCounts, float[] winsByMonumentProximity, ArrayList<PVector> winRatesData, Config conf) {
    logClusterSizeCountsWins(clusterSizeCounts, winsByClusterSize);
    if (conf.getNumMonuments() > 0 && !conf.getLocalisedMonuments()) {
      logMonumentProximityCountsWins(monumentProximityCounts, winsByMonumentProximity);
    }
    logWinRates(winRatesData);
  }

  public void saveJSON() {
    data.setJSONArray("rounds", rounds);
    saveJSONObject(data, logName);
  }
}
