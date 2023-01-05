public class Game extends GViewListener {
  public void update() {
    PGraphics graphicsHandle = getGraphics();
    graphicsHandle.beginDraw();
    graphicsHandle.background(255);
    
    drawGrid(graphicsHandle);
    drawAgents(graphicsHandle);
    
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
  
  private void drawAgents(PGraphics graphicsHandle) {
    ArrayList<Agent> agents = server.getAgents();
    graphicsHandle.strokeWeight(3);
    
    for (int index = 0; index < config.getNumAgents(); index++) {
      Agent agent = agents.get(index);
      GridPosition position = agent.getGridPosition();
      int xCoord = position.getX();
      int yCoord = position.getY();
      
      float gap = float(width()) / float(config.getGridSize());
      
      float xPosition = gap * (float(xCoord) + 0.5);
      float yPosition = gap * (float(yCoord) + 0.5);
      
      graphicsHandle.circle(xPosition, yPosition, AGENT_WIDTH*gap);
    }
  }
}
