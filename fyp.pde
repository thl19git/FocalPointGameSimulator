import g4p_controls.*;
import java.util.Collections;
import java.util.HashSet;
import java.util.HashMap;
import java.util.Arrays;
import java.awt.Font;

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
String[] subgames = {"CONSENSUS","MAJORITY"};

GView gameView;
Game game;
Config config;
Server server;

GButton playButton;
GButton restartButton;

GTextField numAgentsField;
GTextField gridSizeField;
GTextField numRoundsField;
GTextField numClustersField;
GTextField numChoicesField;
GTextField numMovesField;
GTextField occupancyField;

GDropList subgameDroplist;

GTextField createTextField(int xPos, int yPos, int min, int max, int def) {
  GTextField field = new GTextField(this, xPos, yPos, 60, 30);
  field.setNumeric(min,max,def);
  field.setText(str(def));
  field.setFont(new Font("Monospaced", Font.PLAIN, 18));
  return field;
}

void drawText() {
  textSize(50);
  textAlign(CENTER);
  text("Focal Point Game Simulator", width/2, height/10);
  
  textAlign(LEFT);
  textSize(25);
  text("Agents", 140, 370);
  text("Grid Size", 140, 420);
  text("Rounds", 140, 470);
  text("Clusters", 140, 520);
  text("Choices", 140, 570);
  text("Moves", 140, 620);
  text("Occupancy", 140, 670);
  text("Subgame", 140, 720);
}

void setup() {
  frameRate(30);
  fullScreen(P2D,2);
  background(100);
  
  cursor(CROSS);
  
  // game requires server, requires config
  config = new Config(10, 30, 10, 4, 6, 4, 4, Subgame.CONSENSUS); // Default settings
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
  
  numAgentsField = createTextField(275, 350, 1, 100, 30);
  gridSizeField = createTextField(275, 400, 3, 10, 10);
  numRoundsField = createTextField(275, 450, 1, 1000, 10);
  numClustersField = createTextField(275, 500, 1, 6, 5);
  numChoicesField = createTextField(275, 550, 1, 1000, 4);
  numMovesField = createTextField(275, 600, 1, 20, 4);
  occupancyField = createTextField(275, 650, 1, 4, 4);
  
  subgameDroplist = new GDropList(this,275,700,160,150);
  subgameDroplist.setItems(subgames, 0);
  
  drawText();
}

void draw() {
  background(100);
  drawText();
  server.run();
}
