public class Game extends GViewListener {
  public void update() {
    PGraphics graphicsHandle = getGraphics();
    graphicsHandle.beginDraw();
    graphicsHandle.background(255);
    
    drawGrid(graphicsHandle);
    
    switch (server.getStage()) {
      case MOVE_DECISION:
        drawMoveDecisionStage(graphicsHandle);
        break;
      case AGENTS_MOVING:
        drawAgentsMovingStage(graphicsHandle);
        break;
      case CLUSTERING:
        drawClusteringStage(graphicsHandle);
        break;
      case VOTING:
        drawVotingStage(graphicsHandle);
        break;
      default:
        println("Update called, stage: ", server.getStage());
    }
    
    graphicsHandle.endDraw();
    
    validate();
  }
  
  private void drawVotingStage(PGraphics graphicsHandle) {
    drawStaticAgents(graphicsHandle, true);
  }
  
  private void drawClusteringStage(PGraphics graphicsHandle) {
    drawStaticAgents(graphicsHandle, false);
  }
  
  private void drawAgentsMovingStage(PGraphics graphicsHandle) {
    drawMovingAgents(graphicsHandle);
  }
  
  private void drawMoveDecisionStage(PGraphics graphicsHandle) {
    drawStaticAgents(graphicsHandle, false);
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
  
  private void drawStaticAgent(PGraphics graphicsHandle, Agent agent, color outlineColor) {
    GridPosition position = agent.getGridPosition();
    int boxPosition = agent.getPositionInBox();
     
    float gap = float(width()) / float(config.getGridSize());
      
    float xPosition = exactNewXPosition(position, boxPosition);
    float yPosition = exactNewYPosition(position, boxPosition);
    
    float sizeScaleFactor = 1.0;
    if (config.getMaxGridOccupancy() > 1) {
      sizeScaleFactor = 0.5;
    }
    
    color agentColor = agentColors[agent.getClusterNumber()];
    
    drawAgent(graphicsHandle, xPosition, yPosition, gap * AGENT_WIDTH * sizeScaleFactor, agentColor, outlineColor);
  }
  
  private void drawStaticAgents(PGraphics graphicsHandle, boolean showVoteResults) {
    ArrayList<Agent> agents = server.getAgents();
    for (Agent agent : agents) {
      color outlineColor = BLACK;
      if (showVoteResults) {
        int ID = agent.getID();
        boolean result = server.getAgentResult(ID);
        if (result) {
          outlineColor = WIN_COLOR;
        } else {
          outlineColor = LOSE_COLOR;
        }
      }
      drawStaticAgent(graphicsHandle, agent, outlineColor);
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
    if (config.getMaxGridOccupancy() > 1) {
      sizeScaleFactor = 0.5;
    }
    
    color agentColor = agentColors[agent.getClusterNumber()];
      
    drawAgent(graphicsHandle, movingXPosition, movingYPosition, gap * AGENT_WIDTH * sizeScaleFactor, agentColor, BLACK);
  }
  
  private void drawMovingAgents(PGraphics graphicsHandle) {
    ArrayList<Agent> agents = server.getAgents();
    for (Agent agent : agents) {
      drawMovingAgent(graphicsHandle, agent);
    }
  }
  
  private float calculateMovingPosition(float position, float nextPosition) {
    return position + (1 + AGENT_MOVE_FRAMES - server.getFramesToMove()) * (nextPosition - position) / AGENT_MOVE_FRAMES;
  }
  
  private void drawAgent(PGraphics graphicsHandle, float xPosition, float yPosition, float size, color agentColor, color outlineColor) {
    graphicsHandle.strokeWeight(3);
    graphicsHandle.stroke(outlineColor);
    graphicsHandle.fill(agentColor);
    graphicsHandle.circle(xPosition, yPosition, size);
    graphicsHandle.noFill();
  }
}
