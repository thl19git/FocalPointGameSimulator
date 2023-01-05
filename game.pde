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
  
  private void drawStaticAgents(PGraphics graphicsHandle) {
    ArrayList<Agent> agents = server.getAgents();
    for (int index = 0; index < agents.size(); index++) {
      Agent agent = agents.get(index);
      GridPosition position = agent.getGridPosition();
      int xCoord = position.getX();
      int yCoord = position.getY();
      
      float gap = float(width()) / float(config.getGridSize());
      
      float xPosition = gap * (float(xCoord) + 0.5);
      float yPosition = gap * (float(yCoord) + 0.5);
      
      drawAgent(graphicsHandle, xPosition, yPosition, gap * AGENT_WIDTH);
    }
  }
  
  private void drawMovingAgents(PGraphics graphicsHandle) {
    ArrayList<Agent> agents = server.getAgents();
    for (int index = 0; index < agents.size(); index++) {
      Agent agent = agents.get(index);
      GridPosition position = agent.getGridPosition();
      GridPosition nextPosition = agent.getNextGridPosition();
      int xCoord = position.getX();
      int yCoord = position.getY();
      int nextXCoord = nextPosition.getX();
      int nextYCoord = nextPosition.getY();
      
      float gap = float(width()) / float(config.getGridSize());
      
      float xPosition = gap * (float(xCoord) + 0.5);
      float yPosition = gap * (float(yCoord) + 0.5);
      
      float nextXPosition = gap * (float(nextXCoord) + 0.5);
      float nextYPosition = gap * (float(nextYCoord) + 0.5);
      
      float movingXPosition = calculateMovingPosition(xPosition, nextXPosition);
      float movingYPosition = calculateMovingPosition(yPosition, nextYPosition);
      
      drawAgent(graphicsHandle, movingXPosition, movingYPosition, gap * AGENT_WIDTH);
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
