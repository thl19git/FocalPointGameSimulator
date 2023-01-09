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
  server.reset();
}
