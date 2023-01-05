import g4p_controls.*;
import java.util.Collections;

final int MAX_GRID_OCCUPANCY = 4;
final int START_ID = 1000;

GView gameView;
Game game;
Config config;
Server server;

void setup() {
  fullScreen(P2D,2);
  background(100);
  
  cursor(CROSS);
  
  // Config object must be created before any others
  config = new Config();
  
  gameView = new GView(this, width/2, 2*(height-2*width/5)/5, 2*width/5, 2*width/5, P2D);
  game = new Game();
  gameView.addListener(game);
  
  server = new Server();
}

void draw() {
  
}
