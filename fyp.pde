import g4p_controls.*;
import org.gicentre.utils.stat.*;
import java.util.Collections;
import java.util.HashSet;
import java.util.HashMap;
import java.util.Arrays;
import java.awt.Font;
import java.util.Objects;

final int START_ID = 1000;
final float AGENT_WIDTH = 0.6;
final int AGENT_MOVE_FRAMES = 30;
final int SHOW_CLUSTERING_FRAMES = 10;
final int SHOW_VOTES_FRAMES = 60;
final color[] INITIAL_AGENT_COLORS = {color(128, 0, 128), color(128, 128, 0), color(0, 128, 128), color(255, 0, 0), color(0, 255, 0), color(0, 0, 255)};
final color BLACK = color(0, 0, 0);
final color WIN_COLOR = color(0, 255, 0);
final color LOSE_COLOR = color(255, 0, 0);
final String[] SUBGAMES = {"CONSENSUS", "MAJORITY"};
color[] agentColors;


GView gameView;
Game game;
VisAndInfoPanel visInfoPanel;
Config config;
Server server;

GButton playButton;
GButton resetButton;
GButton placementButton;

GTextField numAgentsField;
GTextField gridSizeField;
GTextField numRoundsField;
GTextField numClustersField;
GTextField numChoicesField;
GTextField numMovesField;
GTextField occupancyField;
GTextField numMonumentsField;
GTextField monumentVisibilityField;

GDropList subgameDroplist;

GCheckbox localisedMonumentsCheckbox;
GCheckbox districtClustersCheckbox;

PlacementStage placementStage = PlacementStage.DISTRICTS;

GTextField createTextField(int xPos, int yPos, int min, int max, int def) {
  GTextField field = new GTextField(this, xPos, yPos, 60, 30);
  field.setNumeric(min, max, def);
  field.setText(str(def));
  field.setFont(new Font("Monospaced", Font.PLAIN, 18));
  return field;
}

GTextField createFloatTextField(int xPos, int yPos, float min, float max, float def) {
  GTextField field = new GTextField(this, xPos, yPos, 60, 30);
  field.setNumeric(min, max, def);
  field.setText(str(def));
  field.setFont(new Font("Monospaced", Font.PLAIN, 18));
  return field;
}

void drawText() {
  textSize(50);
  textAlign(CENTER);
  text("Focal Point Game Simulator", width/2, height/15);

  textSize(25);
  text("Agents", 325, 120);
  text("Grid Size", 475, 120);
  text("Rounds", 625, 120);
  text("Clusters", 775, 120);
  text("Choices", 925, 120);
  text("Moves", 1075, 120);
  text("Occupancy", 1225, 120);
  text("Monuments", 1375, 120);
  text("Visibility", 1525, 120);
  text("Subgame", 1725, 120);
  
  textSize(20);
  text("Localised", 190, 110);
  text("monuments", 190, 130);
  text("District", 190, 160);
  text("clusters", 190, 180);
}

void setup() {
  frameRate(30);
  fullScreen(P2D, 2);
  background(100);

  cursor(CROSS);

  // game requires server, requires config
  config = new Config(10, 30, 10, 4, 6, 4, 4, 4, 3, false, false, Subgame.CONSENSUS); // Default settings
  visInfoPanel = new VisAndInfoPanel(this, 8*width/15, 7*height/27, 2*width/5, 2*width/5);
  server = new Server();

  gameView = new GView(this, width/15, 7*height/27, 2*width/5, 2*width/5, P2D);
  game = new Game();
  gameView.addListener(game);

  visInfoPanel.setItemBeingPlaced("Districts");

  G4P.setGlobalColorScheme(G4P.ORANGE_SCHEME);
  G4P.setDisplayFont("Arial", G4P.PLAIN, 20);

  playButton = new GButton(this, 770, 200, 150, 50, "Configure");
  playButton.addEventHandler(this, "handlePlayButton");

  resetButton = new GButton(this, 1000, 200, 150, 50, "Reset");
  resetButton.addEventHandler(this, "handleResetButton");

  placementButton = new GButton(this, 205, 200, 200, 50, "Place agents");
  placementButton.addEventHandler(this, "handlePlacementButton");
  placementButton.setEnabled(false);
  placementButton.setVisible(false);
  
  localisedMonumentsCheckbox = new GCheckbox(this, 115, 105, 10, 10);
  districtClustersCheckbox = new GCheckbox(this, 115, 155, 10, 10);
  districtClustersCheckbox.addEventHandler(this, "handleDistrictClustersCheckboxEvents");

  numAgentsField = createTextField(295, 140, 1, 100, 30);
  gridSizeField = createTextField(445, 140, 3, 20, 10);
  numRoundsField = createTextField(595, 140, 1, 1000, 10);
  numClustersField = createTextField(745, 140, 1, 6, 6);
  numChoicesField = createTextField(895, 140, 1, 1000, 4);
  numMovesField = createTextField(1045, 140, 1, 20, 4);
  occupancyField = createTextField(1195, 140, 1, 4, 4);
  numMonumentsField = createTextField(1345, 140, 0, 50, 4);
  monumentVisibilityField = createFloatTextField(1495, 140, 0, 20, 3);

  subgameDroplist = new GDropList(this, 1645, 140, 160, 150); //1555, 140, 160, 150
  subgameDroplist.setItems(SUBGAMES, 0);

  drawText();
}

void draw() {
  background(100);
  drawText();
  visInfoPanel.update();
  server.run();
}
