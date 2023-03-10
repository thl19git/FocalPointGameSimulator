import g4p_controls.*;
import org.gicentre.utils.stat.*;
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
final String[] SUBGAMES = {"CONSENSUS","MAJORITY"};
color[] agentColors;


GView gameView;
Game game;
DataVisualiser dataVisualiser;
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
  text("Focal Point Game Simulator", width/2, height/15);
  
  textSize(25);
  text("Agents", 385, 120);
  text("Grid Size", 535, 120);
  text("Rounds", 685, 120);
  text("Clusters", 835, 120);
  text("Choices", 985, 120);
  text("Moves", 1135, 120);
  text("Occupancy", 1285, 120);
  text("Subgame", 1485, 120);
}

void setup() {
  frameRate(30);
  fullScreen(P2D,1);
  background(100);
  
  cursor(CROSS);
  
  // game requires server, requires config
  config = new Config(10, 30, 10, 4, 6, 4, 4, Subgame.CONSENSUS); // Default settings
  server = new Server();
  
  gameView = new GView(this, width/15, 7*height/27, 2*width/5, 2*width/5, P2D);
  game = new Game();
  gameView.addListener(game);
  
  dataVisualiser = new DataVisualiser(this, 8*width/15, 7*height/27, 2*width/5, 2*width/5);
  
  G4P.setGlobalColorScheme(G4P.ORANGE_SCHEME);
  G4P.setDisplayFont("Arial", G4P.PLAIN, 20);
  
  playButton = new GButton(this, 770, 200, 150, 50, "Pause");
  playButton.addEventHandler(this, "handlePlayButton");
  
  restartButton = new GButton(this, 1000, 200, 150, 50, "Restart");
  restartButton.addEventHandler(this, "handleRestartButton");
  
  numAgentsField = createTextField(355, 140, 1, 100, 30);
  gridSizeField = createTextField(505, 140, 3, 10, 10);
  numRoundsField = createTextField(655, 140, 1, 1000, 10);
  numClustersField = createTextField(805, 140, 1, 6, 6);
  numChoicesField = createTextField(955, 140, 1, 1000, 4);
  numMovesField = createTextField(1105, 140, 1, 20, 4);
  occupancyField = createTextField(1255, 140, 1, 4, 4);
  
  subgameDroplist = new GDropList(this,1405,140,160,150);
  subgameDroplist.setItems(SUBGAMES, 0);
  
  drawText();
}

void draw() {
  background(100);
  drawText();
  dataVisualiser.update();
  server.run();
}
