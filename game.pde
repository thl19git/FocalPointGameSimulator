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
    
    int gap = round(float(width()) / float(config.gridSize));
    for (int position = gap; position < width(); position += gap) {
      graphicsHandle.line(position, 0, position, height());
      graphicsHandle.line(0, position, width(), position);
    }
    
    println(width());
    println(gap);
  }
}
