import g4p_controls.*;
import java.util.Collections;
import java.util.HashSet;
import java.util.HashMap;
import java.util.Arrays;

final int START_ID = 1000;
final float AGENT_WIDTH = 0.6;
final int AGENT_MOVE_FRAMES = 30;
final int SHOW_CLUSTERING_FRAMES = 30;
final int SHOW_VOTES_FRAMES = 60;
final color[] INITIAL_AGENT_COLORS = {color(128,0,128), color(128, 128, 0), color(0, 128, 128), color(255, 0, 0), color(0, 255, 0), color(0, 0, 255)};
final color BLACK = color(0,0,0);
final color WIN_COLOR = color(0,255,0);
final color LOSE_COLOR = color(255,0,0);
color[] agentColors;

GView gameView;
Game game;
Config config;
Server server;

GButton playButton;
GButton restartButton;

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
  
  G4P.setGlobalColorScheme(G4P.ORANGE_SCHEME);
  G4P.setDisplayFont("Arial", G4P.PLAIN, 20);
  
  playButton = new GButton(this, 275, 200, 150, 50, "Pause");
  playButton.addEventHandler(this, "handlePlayButton");
  
  restartButton = new GButton(this, 275, 275, 150, 50, "Restart");
  restartButton.addEventHandler(this, "handleRestartButton");
  
  textSize(50);
  textAlign(CENTER);
  text("Focal Point Game Simulator", width/2, height/10);
}

void draw() {
  server.run();
}
