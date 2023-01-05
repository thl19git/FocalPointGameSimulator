import g4p_controls.*;

GView gameView;
Game game;
Config config;

void setup() {
  fullScreen(P2D);
  background(100);
  
  cursor(CROSS);
  
  config = new Config();
  
  gameView = new GView(this, width/2, 2*(height-2*width/5)/5, 2*width/5, 2*width/5, P2D);
  game = new Game();
  gameView.addListener(game);
}

void draw() {
  
}
