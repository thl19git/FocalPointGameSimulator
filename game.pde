public class Game extends GViewListener {
  private int sX, sY, eX, eY;
  
  public void update() {
    PGraphics graphicsHandle = getGraphics();
    graphicsHandle.beginDraw();
    graphicsHandle.background(255);
    
    drawGrid(graphicsHandle);
    
    if (server.getStage() == GameStage.CONFIGURATION) {
      graphicsHandle.endDraw();
      validate();
      return; // Other things have not been initialised
    }
    
    drawMonuments(graphicsHandle);
    
    if (server.getStage() == GameStage.PLACING) {
      drawDistricts(graphicsHandle, true);
      drawStaticAgents(graphicsHandle, false);
      if (placementStage == PlacementStage.DISTRICTS) {
        drawSelectedSquare(graphicsHandle);
      }
      graphicsHandle.endDraw();
      validate();
      return; // Other things have not been initialised
    }
    
    drawDistricts(graphicsHandle, false);
    
    switch (server.getStage()) {
      case CONFIGURATION:
        break;
      case PLACING:
        break;
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
  
  private void drawSelectedSquare(PGraphics graphicsHandle) {
    if (!isMousePressed() || !isMouseOver()) {
      return;
    }
    graphicsHandle.rectMode(CORNERS);
    graphicsHandle.fill(100, 50);
    graphicsHandle.rect(sX, sY, eX, eY);
    graphicsHandle.rectMode(CORNER);
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
  
  private void drawMonument(PGraphics graphicsHandle, Monument monument) {
    GridPosition position = monument.getPosition();
    float xCoord = position.getX();
    float yCoord = position.getY();
    float gap = float(width()) / float(config.getGridSize());
    graphicsHandle.stroke(color(0,0,0));
    graphicsHandle.strokeWeight(3);
    graphicsHandle.fill(0);
    graphicsHandle.quad(gap * (xCoord + 0.375), gap * (yCoord + 0.25), gap * (xCoord + 0.625), gap * (yCoord + 0.25), gap * (xCoord + 0.75), gap * (yCoord + 0.75), gap * (xCoord + 0.25), gap * (yCoord + 0.75));
    graphicsHandle.textAlign(CENTER, CENTER);
    graphicsHandle.fill(255);
    graphicsHandle.textSize(20);
    graphicsHandle.text(monument.getText(), gap * (xCoord + 0.5), gap * (yCoord + 0.5));
  }
  
  private void drawMonuments(PGraphics graphicsHandle) {
    ArrayList<Monument> monuments = server.getMonuments();
    for (Monument monument : monuments) {
      drawMonument(graphicsHandle, monument);
    }
  }
  
  private void drawDistrict(PGraphics graphicsHandle, District district, boolean shade) {
    graphicsHandle.stroke(color(255,0,0));
    graphicsHandle.strokeWeight(5);
    float gap = float(width()) / float(config.getGridSize());
    
    float leftX = district.getTopLeft().getX() * gap;
    float rightX = (district.getBottomRight().getX() + 1) * gap;
    float topY = district.getTopLeft().getY() * gap;
    float bottomY = (district.getBottomRight().getY() + 1) * gap;
    
    if (district.getTopLeft().getY() != 0) {
      graphicsHandle.line(leftX, topY, rightX, topY);
    }
    if (district.getBottomRight().getY() != config.getGridSize() - 1) {
      graphicsHandle.line(leftX, bottomY, rightX, bottomY);
    }
    if (district.getTopLeft().getX() != 0) {
      graphicsHandle.line(leftX, topY, leftX, bottomY);
    }
    if (district.getBottomRight().getX() != config.getGridSize() - 1) {
      graphicsHandle.line(rightX, topY, rightX, bottomY);
    }
    
    if (shade == true) {
      graphicsHandle.noStroke();
      graphicsHandle.fill(100, 80);
      graphicsHandle.rectMode(CORNERS);
      graphicsHandle.rect(leftX, topY, rightX, bottomY);
      graphicsHandle.rectMode(CORNER);
    }
    
    graphicsHandle.stroke(color(0,0,0));
  }
  
  private void drawDistricts(PGraphics graphicsHandle, boolean shade) {
    ArrayList<District> districts = server.getDistricts();
    for (District district : districts) {
      drawDistrict(graphicsHandle, district, shade);
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
  
  public GridPosition coordsToGridPosition(int xCoord, int yCoord) {
    float gap = float(width()) / float(config.getGridSize());
    return new GridPosition(floor(xCoord / gap), floor(yCoord / gap));
  }
  
  private void createNewDistrict() {
    int leftX = min(sX, eX);
    int rightX = max(sX, eX);
    int topY = min(sY, eY);
    int bottomY = max(sY, eY);
    
    GridPosition topLeft = coordsToGridPosition(leftX, topY);
    GridPosition bottomRight = coordsToGridPosition(rightX, bottomY);
    
    District district = new District(topLeft, bottomRight);
    server.tryAddDistrict(district);
  }
  
  private void createNewMonument() {
    GridPosition position = coordsToGridPosition(eX,eY);
    server.tryAddMonument(position);
  }
  
  private void createNewAgent() {
    GridPosition position = coordsToGridPosition(eX,eY);
    server.tryAddAgent(position);
  }
  
  public void mousePressed() {
    sX = pmouseX();
    eX = pmouseX();
    sY = pmouseY();
    eY = pmouseY();
  }
  
  public void mouseDragged() {
    eX = pmouseX();
    eY = pmouseY();
  }
  
  public void mouseReleased() {
    eX = pmouseX();
    eY = pmouseY();
    if (server.getStage() == GameStage.PLACING) {
      switch (placementStage) {
        case MONUMENTS:
          createNewMonument();
          break;
        case DISTRICTS:
          createNewDistrict();
          break;
        case AGENTS:
          createNewAgent();
          break;
        default:
          println("game - mouseReleased, defualt in switch statement");
      }
    }
  }
}
