public class Game extends GViewListener {
  public void update() {
    PGraphics graphicsHandle = getGraphics();
    graphicsHandle.beginDraw();
    graphicsHandle.background(255);
    drawGrid(graphicsHandle);
    graphicsHandle.endDraw();
    
    validate();
  }
  
  private void drawGrid(PGraphics graphicsHandle) {
    graphicsHandle.stroke(color(0,0,0));
    graphicsHandle.strokeWeight(5);
    
    float gap = float(width()) / float(config.getGridSize());
    for (float position = gap; position < width() - gap / 2; position += gap) {
      int actualPosition = round(position);
      graphicsHandle.line(actualPosition, 0, actualPosition, height());
      graphicsHandle.line(0, actualPosition, width(), actualPosition);
    }
  }
}
