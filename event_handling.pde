public void handlePlayButton(GButton button, GEvent event) {
  if (button.getText() == "Play") {
    button.setText("Pause");
  } else {
    button.setText("Play");
  }
  server.togglePaused();
}

public void handleRestartButton(GButton button, GEvent event) {
  playButton.setText("Pause");
  // Retrieve values from text fields
  int numAgents = numAgentsField.getValueI();
  int gridSize = gridSizeField.getValueI();
  int numRounds = numRoundsField.getValueI();
  int numClusters = numClustersField.getValueI();
  int numChoices = numChoicesField.getValueI();
  int numMoves = numMovesField.getValueI();
  int occupancy = occupancyField.getValueI();
  int numMonuments = numMonumentsField.getValueI();
  String subgame = subgameDroplist.getSelectedText();
  // Update config
  config = new Config(gridSize, numAgents, numRounds, occupancy, numClusters, numChoices, numMoves, numMonuments, Subgame.valueOf(subgame));
  // Update any text fields that may have had different values used
  numAgentsField.setText(str(config.getNumAgents()));
  numClustersField.setText(str(config.getNumClusters()));
  occupancyField.setText(str(config.getMaxGridOccupancy()));
  numMonumentsField.setText(str(config.getNumMonuments()));
  server.reset();
}
