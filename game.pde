public class Game extends GViewListener {
  public void update() {
    PGraphics graphicsHandle = getGraphics();
    graphicsHandle.beginDraw();
    graphicsHandle.background(255);
    
    drawGrid(graphicsHandle);
    
    if (server.getAgentsMoving()) {
      drawMovingAgents(graphicsHandle);
    } else {
      drawStaticAgents(graphicsHandle);
    }
    
    graphicsHandle.endDraw();
    
    validate();
  }
  
  private void drawGrid(PGraphics graphicsHandle) {
    graphicsHandle.stroke(color(0,0,0));
    graphicsHandle.strokeWeight(5);
    
    float gap = float(width()) / float(config.getGridSize());
    for (float position = gap; position < width() - gap / 2; position += gap) {
      graphicsHandle.line(position, 0, position, height());
      graphicsHandle.line(0, position, width(), position);
    }
  }
  
  private float exactYPosition(int yCoord, int boxPosition, int occupancy) {
    float gap = float(width()) / float(config.getGridSize());
    float offset = 0;
    
    if (occupancy == 1 || occupancy == 2) {
      offset = 0.5;
    } else if (boxPosition < 3) {
      offset = 0.25;
    } else {
      offset = 0.75;
    }
    
    return gap * (float(yCoord) + offset);
  }
  
  private float exactOldYPosition(GridPosition position, int boxPosition) {
    int yCoord = position.getY();
    int occupancy = server.oldGridOccupancyAtPosition(position);
    
    return exactYPosition(yCoord, boxPosition, occupancy);
  }
  
  private float exactNewYPosition(GridPosition position, int boxPosition) {
    int yCoord = position.getY();
    int occupancy = server.gridOccupancyAtPosition(position);
    
    return exactYPosition(yCoord, boxPosition, occupancy);
  }
  
  private float exactXPosition(int xCoord, int boxPosition, int occupancy) {
    float gap = float(width()) / float(config.getGridSize());
    float offset = 0;
    
    if (occupancy == 1 || (occupancy == 3 && boxPosition == 3)) {
      offset = 0.5;
    } else if (boxPosition == 1 || boxPosition == 3) {
      offset = 0.25;
    } else {
      offset = 0.75;
    }
    
    return gap * (float(xCoord) + offset);
  }
  
  private float exactOldXPosition(GridPosition position, int boxPosition) {
    int xCoord = position.getX();
    int occupancy = server.oldGridOccupancyAtPosition(position);
    
    return exactXPosition(xCoord, boxPosition, occupancy);
  }
  
  private float exactNewXPosition(GridPosition position, int boxPosition) {
    int xCoord = position.getX();
    int occupancy = server.gridOccupancyAtPosition(position);
    
    return exactXPosition(xCoord, boxPosition, occupancy);
  }
  
  private void drawStaticAgent(PGraphics graphicsHandle, Agent agent) {
    GridPosition position = agent.getGridPosition();
    int boxPosition = agent.getPositionInBox();
     
    float gap = float(width()) / float(config.getGridSize());
      
    float xPosition = exactNewXPosition(position, boxPosition);
    float yPosition = exactNewYPosition(position, boxPosition);
    
    float sizeScaleFactor = 1.0;
    if (MAX_GRID_OCCUPANCY > 1) {
      sizeScaleFactor = 0.5;
    }
      
    drawAgent(graphicsHandle, xPosition, yPosition, gap * AGENT_WIDTH * sizeScaleFactor);
  }
  
  private void drawStaticAgents(PGraphics graphicsHandle) {
    ArrayList<Agent> agents = server.getAgents();
    for (int index = 0; index < agents.size(); index++) {
      Agent agent = agents.get(index);
      drawStaticAgent(graphicsHandle, agent);
    }
  }
  
  
  private void drawMovingAgent(PGraphics graphicsHandle, Agent agent) {
    GridPosition position = agent.getGridPosition();
    GridPosition nextPosition = agent.getNextGridPosition();
      
    float gap = float(width()) / float(config.getGridSize());
      
    int boxPosition = agent.getPositionInBox();
    int nextBoxPosition = agent.getNextPositionInBox();
    
    float xPosition = exactOldXPosition(position, boxPosition);
    float yPosition = exactOldYPosition(position, boxPosition);
    float nextXPosition = exactNewXPosition(nextPosition, nextBoxPosition);
    float nextYPosition = exactNewYPosition(nextPosition, nextBoxPosition);
      
    float movingXPosition = calculateMovingPosition(xPosition, nextXPosition);
    float movingYPosition = calculateMovingPosition(yPosition, nextYPosition);
    
    float sizeScaleFactor = 1.0;
    if (MAX_GRID_OCCUPANCY > 1) {
      sizeScaleFactor = 0.5;
    }
      
    drawAgent(graphicsHandle, movingXPosition, movingYPosition, gap * AGENT_WIDTH * sizeScaleFactor);
  }
  
  private void drawMovingAgents(PGraphics graphicsHandle) {
    ArrayList<Agent> agents = server.getAgents();
    for (int index = 0; index < agents.size(); index++) {
      Agent agent = agents.get(index);
      drawMovingAgent(graphicsHandle, agent);
    }
  }
  
  private float calculateMovingPosition(float position, float nextPosition) {
    return position + (1 + AGENT_MOVE_FRAMES - server.getFramesToMove()) * (nextPosition - position) / AGENT_MOVE_FRAMES;
  }
  
  private void drawAgent(PGraphics graphicsHandle, float xPosition, float yPosition, float size) {
    graphicsHandle.strokeWeight(3);
    graphicsHandle.fill(color(128,0,128));
    graphicsHandle.circle(xPosition, yPosition, size);
    graphicsHandle.noFill();
  }
}
