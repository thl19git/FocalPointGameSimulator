public void handlePlayButton(GButton button, GEvent event) {
  if (button.getText() == "Play") {
    button.setText("Pause");
  } else {
    button.setText("Play");
  }
  server.togglePaused();
}
