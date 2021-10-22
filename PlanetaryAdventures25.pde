//Refactoring On from Iteration 8: 15.06.2018 
//Primary aim of refactoring is to cast SideBar class in a more reusable form
//Emphasis is on Code Reusability...And Don't forget the famous Arrow class

//Grand Success Need not to explicitly draw SideBar. Handled in the SideBar class itself.

// Refactoring after Nearly 3  Years. 22.10.2021 Friday Iteration 25.

Attractor sun;
ArrayList<Planet> planets;
SideBar sb;
SideBar SB;
TextBar txtBar, txtBarSB, txtBarsb;
int highlightedPlanetIndex = -1;

float zoomFactor = 0.575; //This is the optimal zoom factor for speed...
float zoomStep = 0.01;

float panX = 0, panY = 0;
float panStep = 5;

float pMouseX, pMouseY;

final boolean showOrbitPoints = false;
PVector velocityAnchor  = new PVector(800, 0);

final int FRAME_RATE = 60;

PImage sbBkImg,SBBkImg;

boolean showTrail = true;

void settings(){
  fullScreen();
  smooth(8);
}


void setup() {
  SBBkImg = loadImage("JupiterSaturn.jpg");
  sbBkImg = loadImage("outer-space-stars-galaxies-planets-background-images.jpg");
  frameRate(FRAME_RATE);
  surface.setTitle("PLANETARY ADVENTURES: KEPLER'S PARADISE");
  sb = new SideBar(this, 0, 2.5*width/3, 2*height/3);
  SB = new SideBar(this, 2*height/3, 2*width/3, height/2);
  sb.setImage(sbBkImg);
  SB.setImage(SBBkImg);

  txtBar = new TextBar(10, 10, (sb.getDrawWidth()-20), sb.barHeight/1.8-10);
  txtBarsb = new TextBar(10, sb.barHeight/1.8+10, (sb.getDrawWidth()-20), sb.barHeight-(sb.barHeight/1.8+20));
  txtBarSB = new TextBar(10, 10, (SB.getDrawWidth()-20), SB.barHeight/2-20);

  txtBar.setTextSize(25);
  txtBarSB.setTextSize(25);

  sb.addChild(txtBarsb);
  sb.addChild(txtBar);
  SB.addChild(txtBarSB);

  String message = "Interactivity\n\n" +
    "Click and drag to add a Planet. The arrow represents the velocity vector.\n" +
    "Press \'h\' or \'H\' to cycle through planets for selection.\n" + 
    "Press \'d\' or \'D\' to delete the selected planet.\n" + 
    "Press 'a','s','w' or 'z' for panning\n" +
    "Orbital parameters for the selected planet are shown in the above text field";

  txtBarsb.setText(message); 
  txtBarsb.setTextSize(25);

  sun = new Attractor();
  planets = new ArrayList<Planet>();

  //  thread("calculateForceandUpdate");
  //  background(0);
}

void draw() {
  
  if (!mousePressed || sb.inFocus() || SB.inFocus()) {
    if(showTrail){
      fill(0, 8);
      noStroke();
      rect(0, 0, width, height);
    } else {
      background(0);
    }
    
    pushMatrix();

      scale(zoomFactor);
      translate(width/2*(1/zoomFactor), height/2*(1/zoomFactor));
      pan(panX, panY);
      sun.show();

      for (Planet p : planets) {
        p.showOrbit(showOrbitPoints);
      }

      for (Planet p : planets) {
        p.calcForce(sun);
        p.update();
        p.show();
        p.showVelocity();
        p.showAcceleration();
        p.showVelocity(velocityAnchor);
      }

    popMatrix();

    if (frameCount%10 == 0) {
      String debugMsg = "Debug Parameters"+
        "\nFrame Rate   : " + String.format("%.02f", frameRate) +
        "\nZoom Factor : " + String.format("%.02f", zoomFactor)+
        "\nhighlightedPlanetIndex : " + highlightedPlanetIndex;
      txtBarSB.setText(debugMsg, ':');
    }

  }

}


void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      zoomFactor += zoomStep;
      if (zoomFactor>1) zoomFactor = 1;
      background(0);
    } else if (keyCode == DOWN) {
      zoomFactor -= zoomStep;
      if (zoomFactor<0.15) zoomFactor = 0.15;
      background(0);
    } else if (keyCode == RIGHT) {
      sb.slideOut();
    } else if (keyCode == LEFT) {
      sb.slideIn();
    }
  } 

  if (key == 'D'||key == 'd') {

    if (planets.size()>0) {
      planets.remove(planets.get(highlightedPlanetIndex++));
      if (highlightedPlanetIndex > (planets.size()-1)) highlightedPlanetIndex = 0;
      if (planets.size()>0) {

        selectPlanet(highlightedPlanetIndex);
      } else {
        txtBar.setText("NO PLANETS AVAILABLE !");
        highlightedPlanetIndex = -1;
      }
      background(0);
    }
  }
  if (key == 'H'||key == 'h') {
    if (planets.size()>0) {
      planets.get(highlightedPlanetIndex++).setHighlighted(false);
      if (highlightedPlanetIndex > (planets.size()-1)) highlightedPlanetIndex = 0;
      selectPlanet(highlightedPlanetIndex);
    }
  }

  if (key == 'a' || key == 'A') {
    panX += panStep;
  } else if (key == 's' || key == 'S') {
    panX -= panStep;
  } else if (key == 'w' || key == 'W') {
    panY += panStep;
  } else if (key == 'z' || key == 'Z') {
    panY -= panStep;
  }

}

void selectPlanet(int index) {
  planets.get(index).setHighlighted(true);
  txtBar.setText(planets.get(index).orbitDescriptor, ':');
  sb.setHandleColor(planets.get(index).planetColor);
}

void mouseDragged() {
  if (sb.inFocus() || SB.inFocus()) {
    return;
  }
  background(0);
  drawScene();
  Arrow arrow  = new Arrow(pMouseX, pMouseY, mouseX, mouseY);
  arrow.show();
}

void mousePressed() {
  if (SB.inFocus() || sb.inFocus()) {
    return;
  }
  pMouseX = mouseX; 
  pMouseY = mouseY;

  noCursor();
}

void mouseReleased() {
  if (sb.inFocus() || SB.inFocus()) {
    return;
  }
  addNewPlanet((mouseX - pMouseX)/Planet.velocityArrowScale, (mouseY - pMouseY)/Planet.velocityArrowScale);
  background(0);
  cursor();
}

void addNewPlanet(float vx, float vy) {
  pushMatrix();
  //Important piece of transformation , I understand? 
  float x = (pMouseX-width/2)/zoomFactor; 
  float y = (pMouseY-height/2)/zoomFactor;
  float mass = 1.0;
  Planet p = new Planet(new PVector(x, y), new PVector(vx, vy), mass, sun);
  try {
    planets.add(p);
  }
  catch(Exception e) {
    e.printStackTrace();
  }

  if (planets.size()==1) {
    highlightedPlanetIndex = 0;
    selectPlanet(highlightedPlanetIndex);
  }
  popMatrix();
}

void drawScene() {
  background(0);
  pushMatrix();
  scale(zoomFactor);
  translate(width/2*(1/zoomFactor), height/2*(1/zoomFactor));
  pan(panX, panY);
  sun.show();
  popMatrix();
}

void pan(float shiftX, float shiftY) {
  translate(shiftX, shiftY);
}
