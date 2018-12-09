
ArrayList<Particle> particles = new ArrayList<Particle>();
int nParticles = 100;
float deltaTime = -1;
float prevTime = 0;
boolean isPlaying = true;

int timeBias = 0;

int startPauseTime = 0;

PVector gravity = new PVector(0, -480);
float defaultRadius = 15;
float defaultMass = 1;

void setup() {
  size(800, 500, P2D);
  ellipseMode(RADIUS);
  addRandomParticles();
}

float getRadius(float mass, float density) {
  // area = pi * radius^2 = mass/density
  return sqrt(mass / (PI * density));
}

PVector forceToVelocity(PVector force, float duration, float mass) {
  return PVector.mult(force, duration / mass);
}

void addRandomParticles() {
  particles.clear();
  for (int i = 0; i < nParticles; i++) {
    float mass = random(69, 181);
    float density = 0.5;
    float radius = getRadius(mass, density);
    
    PVector appliedForce = new PVector(random(960000) - 480000, random(960000) - 480000);  /*new PVector(480000, 480000);*/
    float duration = 0.0625;
    PVector velocity = forceToVelocity(appliedForce, duration, mass);
    
    Particle p = new Particle(new PVector(random(width), random(height)), velocity, gravity, radius, mass, true);
    
    particles.add(p);
  }
}

void addTwoCollidingParticles() {
  particles.clear();
  float density = 0.5;
  
  float m1 = random(50, 200);
  float r1 = getRadius(m1, density);
  float m2 = random(50, 200);
  float r2 = getRadius(m2, density);
  
  PVector pos1 = new PVector(random(width), random(height));
  Particle p1 = new Particle(pos1, new PVector(0, 0), new PVector(0, 0), r1, m1, true);
  
  PVector pos2 = new PVector(random(width), random(height));
  PVector v2 = PVector.sub(pos1, pos2);
  v2.setMag(300);
  Particle p2 = new Particle(pos2, v2, new PVector(0, 0), r2, m2, true);
  
  particles.add(p1);
  particles.add(p2);
}

void draw() {
  background(0);
  for (Particle p : particles) {
    if (p.collisionsOn) {
      if (p.hasCollided) {
        p.hasCollided = false;
      } else {
        for (Particle other : particles) {
          float intersectionDist = p.intersectionDist(other);
          if (! p.equals(other) && other.collisionsOn && intersectionDist <= 0) {
            intersectionDist *= -1;
            
            float m1 = p.mass;
            PVector v1i = p.velocity;
            float m2 = other.mass;
            PVector v2i = other.velocity;
            PVector newPVelocity = PVector.add(PVector.mult(v1i, (m1 - m2) / (m1 + m2)), PVector.mult(v2i, 2 * m2 / (m1 + m2)));
            PVector newOtherVelocity = PVector.add(PVector.mult(v1i, 2 * m1 / (m1 + m2)), PVector.mult(v2i, (m2 - m1) / (m1 + m2)));
            
            float DiffAngle = PVector.sub(p.position, other.position).heading();
            PVector extraPos = PVector.fromAngle(DiffAngle);
            extraPos.setMag(intersectionDist / 2);
            p.position.add(extraPos);
            extraPos.rotate(PI);
            other.position.add(extraPos);
            
            p.velocity = newPVelocity;
            other.velocity = newOtherVelocity;
            
            other.hasCollided = true;
          }
        }
      }
      
    }
  }
  for (Particle p : particles) {
    p.advance(deltaTime);
    p.show();
  }
  //println(frameRate);
  deltaTime = getTime() - prevTime;
  prevTime = getTime();
}

void keyPressed() {
  if (key == 'r') {
    addRandomParticles();
    //addTwoCollidingParticles();
    if (!isPlaying)
      play();
  } else if (key == ' ') {
    if (isPlaying)
      pause();
    else
      play();
  } else if (key == 'f') {
    for (Particle p : particles) {
      float mag = 100000;
      //PVector f = new PVector(random(mag) - mag / 2.0, random(mag) - mag / 2.0);
      PVector f = new PVector(10000, 10000);
      p.applyForce(f);
    }
  }
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
