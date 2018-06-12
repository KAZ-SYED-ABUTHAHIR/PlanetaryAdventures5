Attractor sun;
ArrayList<Planet> planets;

float zoomFactor = 1.0;
float zoomStep = 0.1;
float pMouseX, pMouseY;

void setup() {
  size(720 ,640, P2D);
  background(0);
  sun = new Attractor();
  planets = new ArrayList<Planet>();
  background(0);
}

void draw() {
  if (!mousePressed) {
    fill(0, 128);
    rect(0, 0, width, height);
    pushMatrix();
    scale(zoomFactor);
    translate(width/2*(1/zoomFactor), height/2*(1/zoomFactor));
    sun.show();
    for (Planet p : planets) {
      p.showOrbit();
    }
    for (Planet p : planets) {
      p.calcForce(sun);
      p.update();
      p.show();
    }
    popMatrix();
  }
}


void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      zoomFactor += zoomStep;
      if (zoomFactor>10) zoomFactor = 10;
      background(0);
    } else if (keyCode == DOWN) {
      zoomFactor -= zoomStep;
      if (zoomFactor<0) zoomFactor = 0;
      background(0);
    }
  } 
  if (key == 'D'||key == 'd')
  {
    try {
      planets.remove(planets.size()-1);
      background(0);
    }
    catch(Exception e) {
      //Who Cares?
    }
  }
}

void mouseDragged() {
  background(0);
  drawScene();
  pushMatrix();

  stroke(200, 100, 200, 200);
  strokeWeight(3);
  fill(200, 150, 125, 200);

  line(pMouseX, pMouseY, mouseX, mouseY);
  //Drawing the arrow head;
  float dX = mouseX - pMouseX; 
  float dY = mouseY - pMouseY;
  float theta = atan2(dY, dX);
  strokeWeight(4);
  line(mouseX, mouseY, mouseX+10*cos(theta-radians(160)), mouseY+10*sin(theta-radians(160)));
  line(mouseX, mouseY, mouseX+10*cos(theta+radians(160)), mouseY+10*sin(theta+radians(160)));
  stroke(50, 100, 255, 200);
  ellipse(pMouseX, pMouseY, 10, 10);
  popMatrix();
}

void mousePressed() {

  pMouseX = mouseX; 
  pMouseY = mouseY;
  noCursor();
}

void mouseReleased() {
  addNewPlanet((mouseX - pMouseX)/40, (mouseY - pMouseY)/40);
  background(0);
  cursor();
}

void addNewPlanet(float vx, float vy) {
  pushMatrix();
  //Important piece of transformation , I don't understand 
  float x = (pMouseX-width/2)/zoomFactor; 
  float y = (pMouseY-height/2)/zoomFactor;
  Planet p = new Planet(new PVector(x, y), new PVector(vx, vy), 0.5, sun);
  planets.add(p);
  popMatrix();
}

void drawScene() {
  background(0);
  pushMatrix();
  scale(zoomFactor);
  translate(width/2*(1/zoomFactor), height/2*(1/zoomFactor));
  sun.show();
  for (Planet p : planets) {
    p.show();
  }
  popMatrix();
}
