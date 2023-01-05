public class Server {
  private ArrayList<Agent> agents;
  private ArrayList<Integer> gridOccupancy;
  
  Server() {
    resetGridOccupancy();
    println("reset occupancy");
    createAgents();
    println("created agents");
  }
  
  private void resetGridOccupancy() {
    int gridSize = config.getGridSize();
    gridOccupancy = new ArrayList<Integer>(Collections.nCopies(gridSize*gridSize, 0));
  }
  
  private void createAgents() {
    agents = new ArrayList<Agent>();
    
    int gridSize = config.getGridSize();
    for (int ID = START_ID; ID < START_ID + config.getNumAgents(); ID++) {
      int randomPosition;
      
      while (true) {
        randomPosition = floor(random(gridSize*gridSize));
        println(randomPosition);
        if (gridOccupancy.get(randomPosition) < MAX_GRID_OCCUPANCY) {
          break;
        }
      }
      
      Integer occupancy = gridOccupancy.get(randomPosition);
      occupancy++;
      
      GridPosition initialPosition = new GridPosition(randomPosition / 10, randomPosition % 10);
      Agent agent = new Agent(ID, initialPosition);
      agents.add(agent);
    }
  }
}
