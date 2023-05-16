public void enableDisableFields(boolean enabled) {
  numAgentsField.setEnabled(enabled);
  gridSizeField.setEnabled(enabled);
  numRoundsField.setEnabled(enabled);
  numClustersField.setEnabled(enabled);
  numChoicesField.setEnabled(enabled);
  numMovesField.setEnabled(enabled);
  occupancyField.setEnabled(enabled);
  numMonumentsField.setEnabled(enabled);
  monumentVisibilityField.setEnabled(enabled);
  subgameDroplist.setEnabled(enabled);
}

public void handlePlayButton(GButton button, GEvent event) {
  if (button.getText() == "Play") {
    button.setText("Pause");
    server.togglePaused();
  } else if (button.getText() == "Pause") {
    button.setText("Play");
    server.togglePaused();
  } else if (button.getText() == "Configure") {
    // Retrieve values from text fields
    int numAgents = numAgentsField.getValueI();
    int gridSize = gridSizeField.getValueI();
    int numRounds = numRoundsField.getValueI();
    int numClusters = numClustersField.getValueI();
    int numChoices = numChoicesField.getValueI();
    int numMoves = numMovesField.getValueI();
    int occupancy = occupancyField.getValueI();
    int numMonuments = numMonumentsField.getValueI();
    float monumentVisibility = monumentVisibilityField.getValueF();
    String subgame = subgameDroplist.getSelectedText();
    
    // Update config
    config = new Config(gridSize, numAgents, numRounds, occupancy, numClusters, numChoices, numMoves, numMonuments, monumentVisibility, Subgame.valueOf(subgame));
    
    // Update any text fields that may have had different values used
    numAgentsField.setText(str(config.getNumAgents()));
    numClustersField.setText(str(config.getNumClusters()));
    occupancyField.setText(str(config.getMaxGridOccupancy()));
    numMonumentsField.setText(str(config.getNumMonuments()));
    monumentVisibilityField.setText(str(config.getMonumentVisibility()));
    
    enableDisableFields(false);
    
    button.setText("Start");
    server.startPlacingStage();
    
    placementButton.setEnabled(true);
    placementButton.setVisible(true);
    placementButton.setText("Place agents");
    placementStage = PlacementStage.DISTRICTS;
    visInfoPanel.setItemBeingPlaced("Districts");
    
  } else { // Text is "Start"
    // Begin the game if grid is covered in districts or has no districts
    if (server.containsDistricts() && !server.isCompletelyCoveredInDistricts()) {
      return;
    }
    server.beginGame();
    button.setText("Pause");
    placementButton.setEnabled(false);
    placementButton.setVisible(false);
  }
}

public void handleResetButton(GButton button, GEvent event) {
  if (playButton.getText() == "Start") {
    // If there are placed objects, remove them
    if (server.containsPlacedObjects()) {
      server.removePlacedObjects();
      game.update(); //try without
    } else {
      // Go to configuration stage
      playButton.setText("Configure");
      server.hardReset();
      enableDisableFields(true);
      placementButton.setEnabled(false);
      placementButton.setVisible(false);
      game.update();
    }
  } else if (playButton.getText() == "Configure") {
    return;
  } else { // Text is "Play" or "Pause"
    playButton.setText("Start");
    server.reset();
    server.startPlacingStage();
    placementButton.setEnabled(true);
    placementButton.setVisible(true);
    game.update();
  }
}

public void handlePlacementButton(GButton button, GEvent event) {
  switch (placementStage) {
    case DISTRICTS:
      if (config.getNumMonuments() == 0) {
        button.setText("Place districts");
      } else {
        button.setText("Place monuments");
      }
      placementStage = PlacementStage.AGENTS;
      visInfoPanel.setItemBeingPlaced("Agents");
      break;
    case MONUMENTS:
      button.setText("Place agents");
      placementStage = PlacementStage.DISTRICTS;
      visInfoPanel.setItemBeingPlaced("Districts");
      break;
    case AGENTS:
      if (config.getNumMonuments() == 0) {
        button.setText("Place agents");
        placementStage = PlacementStage.DISTRICTS;
        visInfoPanel.setItemBeingPlaced("Districts");
      } else {
        button.setText("Place districts");
        placementStage = PlacementStage.MONUMENTS;
        visInfoPanel.setItemBeingPlaced("Monuments");
      }
      break;
    default:
      println("handlePlacementButton - switch statement default case");
  }
}
