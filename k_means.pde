public void kMeansClustering(ArrayList<Agent> agents) {
  HashSet<GridPosition> centroidSet = new HashSet<GridPosition>();
  int clusters = config.getNumClusters();
  
  // Performance degrades as clusters / gridSize increases, but okay for now (ensures unique centroids initially)
  while (centroidSet.size() < clusters) {
    //centroidSet.add(randomGridPosition());
    centroidSet.add(agents.get(floor(random(agents.size()))).getGridPosition());
  }
  GridPosition[] centroids = new GridPosition[clusters];
  centroidSet.toArray(centroids);
  
  updateCentroidsAndClusters(agents, centroids);
}

public void updateCentroidsAndClusters(ArrayList<Agent> agents, GridPosition[] centroids) {
  int clusters = config.getNumClusters();
  
  while (true) {
    boolean assignmentChanged = false;
    
    int[] xPositions = new int[clusters];
    int[] yPositions = new int[clusters];
    int[] agentsPerCluster = new int[clusters];
    
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
      int xPosition = xPositions[index] / numAgents;
      int yPosition = yPositions[index] / numAgents;
      centroids[index] = new GridPosition(xPosition, yPosition);
    }
  }
  sortColors(centroids); // Reduces amount of color switching (not perfect but better than nothing)
}

public void sortColors(GridPosition[] centroids) {
  GridPosition[] sortedCentroids = centroids.clone();
  Arrays.sort(sortedCentroids);
  for (int index = 0; index < centroids.length; index++) {
    int unsortedIndex = Arrays.asList(centroids).indexOf(sortedCentroids[index]);
    agentColors[unsortedIndex] = INITIAL_AGENT_COLORS[index];
  }
}

public int assignCluster(GridPosition agentPosition, GridPosition[] centroids) {
  int nearest = -1;
  int minDistance = 10000; // A large number
  
  for (int index = 0; index < centroids.length; index++) {
    GridPosition centroid = centroids[index];
    int squaredDistance = squaredEuclideanDistance(agentPosition, centroid);
    if (squaredDistance < minDistance) {
      minDistance = squaredDistance;
      nearest = index;
    }
  }
  
  return nearest;
}

public int squaredEuclideanDistance(GridPosition agentPosition, GridPosition centroidPosition) {
  int agentX = agentPosition.getX();
  int centroidX = centroidPosition.getX();
  
  int agentY = agentPosition.getY();
  int centroidY = centroidPosition.getY();
  
  int diffX = agentX - centroidX;
  int diffY = agentY - centroidY;
  
  return diffX * diffX + diffY * diffY;
}
