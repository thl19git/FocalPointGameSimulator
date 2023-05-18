public int[] kMeansClustering(int clusters, ArrayList<Agent> agents) {
  HashSet<FractionalGridPosition> centroidSet = new HashSet<FractionalGridPosition>();

  // Performance degrades as clusters / gridSize increases, but okay for now (ensures unique centroids initially)
  while (centroidSet.size() < clusters) {
    centroidSet.add(new FractionalGridPosition(agents.get(floor(random(agents.size()))).getGridPosition()));
  }
  FractionalGridPosition[] centroids = new FractionalGridPosition[clusters];
  centroidSet.toArray(centroids);

  return updateCentroidsAndClusters(clusters, agents, centroids);
}

public int[] updateCentroidsAndClusters(int clusters, ArrayList<Agent> agents, FractionalGridPosition[] centroids) {
  int[] agentsPerCluster;
  while (true) {
    boolean assignmentChanged = false;

    int[] xPositions = new int[clusters];
    int[] yPositions = new int[clusters];
    agentsPerCluster = new int[clusters];

    for (Agent agent : agents) {
      int newCluster = assignCluster(agent.getGridPosition(), centroids);
      int oldCluster = agent.getClusterNumber();

      agent.setClusterNumber(newCluster);

      if (newCluster != oldCluster) {
        assignmentChanged = true;
      }

      xPositions[newCluster] += agent.getGridPosition().getX();
      yPositions[newCluster] += agent.getGridPosition().getY();
      agentsPerCluster[newCluster]++;
    }

    if (!assignmentChanged) {
      break;
    }

    for (int index = 0; index < clusters; index++) {
      int numAgents = agentsPerCluster[index];
      if (numAgents == 0) {
        continue;
      }
      float xPosition = xPositions[index] / numAgents;
      float yPosition = yPositions[index] / numAgents;
      centroids[index] = new FractionalGridPosition(xPosition, yPosition);
    }
  }
  sortColors(centroids); // Reduces amount of color switching (not perfect but better than nothing)
  return agentsPerCluster;
}

public void sortColors(FractionalGridPosition[] centroids) {
  FractionalGridPosition[] sortedCentroids = centroids.clone();
  Arrays.sort(sortedCentroids);
  for (int index = 0; index < centroids.length; index++) {
    int unsortedIndex = Arrays.asList(centroids).indexOf(sortedCentroids[index]);
    agentColors[unsortedIndex] = INITIAL_AGENT_COLORS[index];
  }
}

public int assignCluster(GridPosition agentPosition, FractionalGridPosition[] centroids) {
  int nearest = -1;
  float minDistance = 10000; // A large number

  for (int index = 0; index < centroids.length; index++) {
    FractionalGridPosition centroid = centroids[index];
    float squaredDistance = squaredEuclideanDistance(agentPosition, centroid);
    if (squaredDistance < minDistance) {
      minDistance = squaredDistance;
      nearest = index;
    }
  }

  return nearest;
}

public float squaredEuclideanDistance(GridPosition agentPosition, FractionalGridPosition centroidPosition) {
  int agentX = agentPosition.getX();
  float centroidX = centroidPosition.getX();

  int agentY = agentPosition.getY();
  float centroidY = centroidPosition.getY();

  float diffX = agentX - centroidX;
  float diffY = agentY - centroidY;

  return diffX * diffX + diffY * diffY;
}
