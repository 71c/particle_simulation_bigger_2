
//ArrayList<Particle> particles = new ArrayList<Particle>();
int nParticles = 100;
boolean isPlaying = true;

float deltaTime = -1;
float prevTime = 0;
int timeBias = 0;
int startPauseTime = 0;


//int startPauseTime = 0;

//PVector gravity = new PVector(0, -480);
//float defaultRadius = 15;
//float defaultMass = 1;

ParticleSystem ps;

void setup() {
  size(800, 500, P2D);
  ellipseMode(RADIUS);
  ps = new ParticleSystem(new PVector(0, -480), true, false);
}


void draw() {
  background(0);
  
  ps.run(deltaTime);
  
  deltaTime = getTime() - prevTime;
  prevTime = getTime();
  
}

void keyPressed() {
  if (key == 'r') {
    ps.addRandomParticles(nParticles, 50, 200, true, 20000, 30000);
    //ps.addTwoCollidingParticles([...]);
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
