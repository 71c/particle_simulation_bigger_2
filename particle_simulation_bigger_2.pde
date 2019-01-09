import controlP5.*;


int nParticles = 2;
boolean isPlaying = true;

float deltaTime = -1;
float prevTime = 0;
int timeBias = 0;
int startPauseTime = 0;

ParticleSystem ps;

ControlP5 cp5;

boolean visualizeVelocity;
boolean visualizeAcceleration;
float minMass = 50;
float maxMass = 200;

Toggle collideToggle;
Slider gravitySlider;
Slider nSlider;

void setup() {
  size(800, 500, P2D);
  ellipseMode(RADIUS);
  ps = new ParticleSystem(new PVector(0, -480), true, true);
  
  cp5 = new ControlP5(this);
  cp5.addButton("addRandomParticles")
     .setValue(0)
     .setPosition(0,0)
     .setSize(100, 20)
     .setLabel("add random particles")
     ;
  cp5.addButton("addTwoCollidingParticles")
     .setBroadcast(false) 
     .setValue(0)
     .setPosition(0,40)
     .setSize(100, 20)
     .setBroadcast(true)
     .setLabel("add 2 colliding particles")
     ;
  cp5.addToggle("showVelocity")
     .setPosition(110,0)
     .setSize(50,20)
     .setCaptionLabel("show velocity")
     ;
  cp5.addToggle("showAcceleration")
     .setPosition(180,0)
     .setSize(50,20)
     .setCaptionLabel("show acceleration")
     ;
  nSlider = cp5.addSlider("changeN")
     .setPosition(100,80)
     //.setSize(100, 20)
     .setRange(0,100)
     .setValue(10)
     .setCaptionLabel("particles")
     ;
  collideToggle = cp5.addToggle("setCollide")
     .setPosition(300,0)
     //.setSize(50,20)
     .setValue(false)
     .setCaptionLabel("collide")
     ;
  gravitySlider = cp5.addSlider("setGravity")
     .setPosition(300,50)
     .setSize(100, 20)
     .setRange(-1000, 0)
     .setValue(-480)
     .setCaptionLabel("g")
     ;
  cp5.addRange("setMassRange")
             // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(400,25)
             .setSize(200,10)
             //.setHandleSize(20)
             .setRange(0,1000)
             .setRangeValues(50,200)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setCaptionLabel("mass range")
             ;
   cp5.addSlider("setElasticity")
     .setPosition(500,50)
     .setSize(100, 20)
     .setRange(0, 1)
     .setValue(1)
     .setCaptionLabel("elasticity")
     ;
}




void draw() {
  background(0);
  
  ps.run(deltaTime);
  
  //if (random(1) < 0.016) {
  //  println(millis() + ", " + ps.totalK());
  //}
  
  deltaTime = getTime() - prevTime;
  prevTime = getTime();
  
}

void keyPressed() {
  if (key == 'r') {
    addRandomParticles();
    //ps.addRandomParticles(nParticles, 50, 200, true, 0, 0);
    //ps.addTwoCollidingParticles(50, 200, 300);
    if (!isPlaying)
      play();
  } else if (key == ' ') {
    if (isPlaying)
      pause();
    else
      play();
  }
  //} else if (key == 'f') {
  //  for (Particle p : particles) {
  //    float mag = 100000;
  //    //PVector f = new PVector(random(mag) - mag / 2.0, random(mag) - mag / 2.0);
  //    PVector f = new PVector(10000, 10000);
  //    p.applyForce(f);
  //  }
  //}
}


void addRandomParticles() {
  //ps.addRandomParticles(nParticles, minMass, maxMass, true, 20000, 30000);
  //ps.addRandomParticles(nParticles, minMass, maxMass, true, 25000, 25000);
  ps.addRandomParticles(nParticles, minMass, maxMass, false, 125, 300);
  // 500 .. 200 .. 125
}

void addTwoCollidingParticles() {
  collideToggle.setValue(true);
  gravitySlider.setValue(0);
  nSlider.setValue(2);
  ps.addTwoCollidingParticles(minMass, maxMass, 300);
}

void showVelocity(boolean theFlag) {
  visualizeVelocity = theFlag;
  ps.setVisualizeVelocity(theFlag);
}

void showAcceleration(boolean theFlag) {
  visualizeAcceleration = theFlag;
  ps.setVisualizeAcceleration(theFlag);
}

void setCollide(boolean theFlag) {
  ps.setCollisionsOn(theFlag);
}

void changeN(int theValue) {
  nParticles = theValue;
  addRandomParticles();
}

void setMassRange(ControlEvent theControlEvent) {
  minMass = theControlEvent.getController().getArrayValue(0);
  maxMass = theControlEvent.getController().getArrayValue(1);
  addRandomParticles();
}

void setGravity(float theValue) {
  ps.setGravity(new PVector(0, theValue));
}

void setElasticity(float e) {
  ps.setElasticity(e);
}

void pause() {
  startPauseTime = millis();
  noLoop();
  deltaTime = 0;
  isPlaying = false;
}

void play() {
  timeBias += startPauseTime - millis();
  loop();
  isPlaying = true;
}

float getTime() {
  return (millis() + timeBias) / 1000.0;
}
