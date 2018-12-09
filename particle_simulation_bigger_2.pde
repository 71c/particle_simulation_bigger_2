
ArrayList<Particle> particles = new ArrayList<Particle>();
int nParticles = 500;
float deltaTime = -1;
float prevTime = 0;
boolean isPlaying = true;

int timeBias = 0;

int startPauseTime = 0;

PVector gravity = new PVector(0, -300);
float defaultRadius = 15;
float defaultMass = 1;

void setup() {
  size(800, 500, P2D);
  //size(200, 125, P2D);
  //fullScreen(P2D);
  ellipseMode(RADIUS);
  addRandomParticles();
  //particles.add(new Particle(new PVector(0, 0), new PVector(300, 300), new PVector(0, -300)));
  
  //frameRate(10);
}

void addRandomParticles() {
  particles.clear();
  //particles = new ArrayList<Particle>();
  for (int i = 0; i < nParticles; i++) {
    //particles.add(new Particle(new PVector(random(width), random(height)), new PVector(random(600) - 300, random(600) - 300), gravity, defaultRadius, defaultMass));
    
    
    //float mass = random(50, 200);
    float mass = random(88, 162);
    //float mass = 125;
    float density = 0.5;
    
    //float mass = random(88, 162);
    //float mass = 125;
    //float density = 8;
    
    float radius = sqrt(mass / (PI * density));
    
    
    Particle p = new Particle(new PVector(random(width), random(height)), new PVector(0, 0), new PVector(0, -60000), radius, mass);
    //Particle p = new Particle(new PVector(random(width), random(height)), new PVector(0, 0), new PVector(0, 0), radius, mass);
    //Particle p = new Particle(new PVector(random(width), random(height)), new PVector(212, 212), new PVector(0, 0), radius, mass);
    //p.applyTimedForce(new PVector(1000, 1000), 1);
    //p.applyTimedForce(new PVector(30000, 30000), 1);
    //p.applyTimedForce(new PVector(30000, 0), 1);
    //p.applyTimedForce(new PVector(30000, 60000), 1);
    //p.applyTimedForce(new PVector(120000, 240000), 0.25);
    //p.applyTimedForce(new PVector(480000, 480000), 0.0625);
    p.applyTimedForce(new PVector(random(960000) - 480000, random(960000) - 480000), 0.0625);
    //p.applyTimedForce(new PVector(0, 0), 0.0625);
    particles.add(p);
    // A = pi r^2
    // d = m/A
    // A = m / d
    // r = sqrt(m / (pi d))
  }
}

void addTwoCollidingParticles() {
  particles.clear();
  float density = 0.5;
  
  float m1 = random(50, 200);
  //float m1 = 1000;
  float r1 = sqrt(m1 / (PI * density));
  float m2 = random(50, 200);
  //float m2 = 1000;
  float r2 = sqrt(m2 / (PI * density));
  
  PVector pos1 = new PVector(random(width), random(height));
  Particle p1 = new Particle(pos1, new PVector(0, 0), new PVector(0, 0), r1, m1);
  
  PVector pos2 = new PVector(random(width), random(height));
  PVector v2 = PVector.sub(pos1, pos2);
  v2.setMag(300);
  Particle p2 = new Particle(pos2, v2, new PVector(0, 0), r2, m2);
  
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
            
            
            //println(n)
                        
            //v1f = (m1 v1i - m2 v1i + 2 m2 v2i) / (m1 + m2)
            //v1f = ((m1 - m2) v1i + (2 m2) v2i) / (m1 + m2)
            //v1f = (m1 - m2) / (m1 + m2) v1i + (2 m2) / (m1 + m2) v2i
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
    //particles.clear();
    //particles.add(new Particle(new PVector(0, 0), new PVector(300, 300), gravity, defaultRadius, defaultMass));
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
