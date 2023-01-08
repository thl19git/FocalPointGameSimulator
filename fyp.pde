import g4p_controls.*;
import java.util.Collections;
import java.util.HashSet;

final int START_ID = 1000;
final float AGENT_WIDTH = 0.6;
final int AGENT_MOVE_FRAMES = 30;

GView gameView;
Game game;
Config config;
Server server;

void setup() {
  frameRate(30);
  fullScreen(P2D,2);
  background(100);
  
  cursor(CROSS);
  
  // game requires server, requires config
  config = new Config();
  server = new Server();
  
  gameView = new GView(this, width/2, 3*(height-2*width/5)/5, 2*width/5, 2*width/5, P2D);
  game = new Game();
  gameView.addListener(game);
}

void draw() {
  server.run();
}
