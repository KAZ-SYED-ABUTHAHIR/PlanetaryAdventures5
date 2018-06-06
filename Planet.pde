class Planet {  //<>//
  PVector position = new PVector();
  PVector velocity = new PVector();
  PVector acceleration = new PVector();
  PVector initialPosition = new PVector();
  Attractor myAttractor;
  ArrayList<PVector> orbitPoints = new ArrayList<PVector>();
  ArrayList<PolarPoint> orbitPolarPoints = new ArrayList<PolarPoint>();
  float orbitalPeriod=-1;
  float maxRadius = -1;
  float minRadius = 50000;
  float minAngle = 0;
  float maxAngle = 0;
  int minIndex = 0;
  int maxIndex = 0;
  float orbitalEccentricity = 0;
  float semiMajorAxis = 0;
  float semiMinorAxis = 0;
  PVector apoapsis = new PVector(); //Farthest point from the attractor
  PVector periapsis = new PVector(); //Closest point to the attractor
  PVector orbitCenter = new PVector(); //Center point of the elliptical orbit

  final private float threshold = 0.5;
  final private int minOrbitPointCount = 100;
  final private int maxOrbitPointCount = 25000;


  float mass;
  float size = 60;
  String name;
  color c ;

  //Constructors

  Planet(PVector _position, PVector _velocity, float _mass) {
    this.position = _position.copy();
    this.initialPosition = this.position.copy();
    this.velocity = _velocity.copy();
    this.mass = _mass;
    this.name = "Planet";
    pushStyle();
    colorMode(HSB);
    c = color(random(255), 255, 255, 255);
    popStyle();
  }

  Planet(PVector _position, PVector _velocity, float _mass, Attractor _attractor) {
    this(_position, _velocity, _mass);
    this.initialPosition = this.position.copy();
    this.myAttractor = _attractor;
    calcOrbit(_attractor);
  }

  Planet(PVector _position, float _mass) {
    this.position = _position.copy();
    this.initialPosition = this.position.copy();
    this.velocity = PVector.random2D();
    this.mass = _mass;
    this.name = "Planet";
    pushStyle();
    colorMode(HSB);
    c = color(random(255), 255, 255, 255);
    popStyle();
  }

  Planet() {
    this.position.x = random(width);
    this.position.y = random(height);
    this.initialPosition = this.position.copy();
    this.velocity = PVector.random2D();
    this.velocity.setMag(random(0.5, 5.0));
    this.mass = random(0.05, 0.5);
    this.name = "Planet";
    pushStyle();
    colorMode(HSB);
    c = color(random(255), 255, 255, 255);
    popStyle();
  }

  //Displayer
  void show() {
    pushStyle();
    fill(c);
    noStroke();
    ellipse(this.position.x, this.position.y, this.size, this.size);
    popStyle();
  }

  //Update : Do Physics...
  void update() {
    this.velocity.add(this.acceleration);
    this.position.add(this.velocity);
    this.acceleration.setMag(0);
  }

  //CalcForce : Calculate Force using Newton's Law of Gravitation
  void calcForce(Attractor attractor) {
    float dist = PVector.dist(this.position, attractor.position);
    PVector radialVector = PVector.sub(attractor.position, this.position).setMag(1);
    acceleration.set(radialVector).setMag(G*attractor.mass/(dist*dist));
  }

  //Orbit calculations. Pretty messy now but works somehow...
  void calcOrbit(Attractor a) {
    PVector radial = PVector.sub(this.position, a.position);
    float initHeading = radial.heading()*180/PI+180.0f;
    float heading; 
    float magnitude;
    int count = 0;
    do {
      PVector pos = this.position.copy();
      orbitPoints.add(pos);
      calcForce(a);
      update();
      radial = PVector.sub(this.position, a.position);
      magnitude = radial.mag();
      heading = radial.heading()*180/PI+180.0f;
      if (magnitude>this.maxRadius) {
        this.maxRadius = magnitude;
        this.maxAngle = heading-180.0f;
        this.maxIndex = count;
      }
      if (magnitude<this.minRadius) {
        this.minRadius = magnitude;
        this.minAngle = heading-180.0f;
        this.minIndex = count;
      }
      count++;
    } while ((abs(heading-initHeading)>this.threshold || count < this.minOrbitPointCount) && !(count>this.maxOrbitPointCount));
    if (orbitPoints.size()<maxOrbitPointCount) {
      this.orbitalPeriod = orbitPoints.size()*(1/frameRate);
    }
    this.orbitalEccentricity = (this.maxRadius-this.minRadius)/(this.maxRadius+this.minRadius);
    this.apoapsis = orbitPoints.get(maxIndex);
    this.periapsis = orbitPoints.get(minIndex);
    this.orbitCenter = PVector.lerp(this.apoapsis, this.periapsis, 0.5);
    this.semiMajorAxis = PVector.sub(this.periapsis, this.apoapsis).mag()/2;
    this.semiMinorAxis = this.semiMajorAxis*sqrt(1-this.orbitalEccentricity*this.orbitalEccentricity);
    float keplerRCubeByTSquare = pow(this.semiMajorAxis, 3)/pow(this.orbitalPeriod, 2);

    println("Orbital Period          : "+this.orbitalPeriod);
    println("Eccentricity            : "+this.orbitalEccentricity);
    println("Semi Major Axis         : "+this.semiMajorAxis);
    println("Semi Minor Axis         : "+this.semiMinorAxis);
    println("Kepler III Law Constant : "+ keplerRCubeByTSquare);
    println("Max Radius              : "+this.maxRadius);
    println("Min Radius              : "+this.minRadius);
    println("Max Angle               : "+this.maxAngle);
    println("Min Angle               : "+this.minAngle);
  }

  void calcPolarOrbit(Attractor a) {
    pushMatrix();
    translate(a.position.x, a.position.y);
    PVector radial = PVector.sub(this.position, a.position);
    print(radial.mag());
    print(" , ");
    println(radial.heading()*180/PI+180.0f);
    popMatrix();
  }

  void showOrbit() {
    pushStyle();
    strokeWeight(3);
    stroke(this.c);
    noFill();
    pushMatrix();
    translate(this.orbitCenter.x, this.orbitCenter.y);
    rotate(radians(this.minAngle));
    ellipse(0, 0, 2*this.semiMajorAxis, 2*this.semiMinorAxis);
    popMatrix();
    stroke(0, 0, 255, 255);
    strokeWeight(20);
    point(orbitPoints.get(minIndex).x, orbitPoints.get(minIndex).y);
    stroke(255, 100, 0, 255);
    point(orbitPoints.get(maxIndex).x, orbitPoints.get(maxIndex).y);
    stroke(255, 100, 255, 255);
    point(this.orbitCenter.x, this.orbitCenter.y);
    popStyle();
  }

  void showRadial(Attractor a) {
    pushStyle();
    stroke(c);
    line(a.position.x, a.position.y, this.position.x, this.position.y);
    popStyle();
  }
}//CLASS_END
