// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector gravity;
  boolean wallBounceOn;
  boolean collisionsOn;
  float density;
  float elasticity = 1;
  
  float totalK() {
    float total = 0;
    for (Particle p : particles) {
      total += p.mass * p.velocity.magSq();
    }
    return total * 0.5;
  }
  
  float totalP() {
    float total = 0;
    for (Particle p : particles) {
      total += p.mass * p.velocity.mag();
    }
    return total;
  }
  
  float totalE() {
    float totalUg = 0;
    for (Particle p : particles) {
      totalUg += p.netForce.mag() * p.position.y;
    }
    return totalUg + totalK();
  }
  
  ParticleSystem(PVector g, boolean collide, boolean bounce) {
    this(g, collide, bounce, 0.5);
  }

  ParticleSystem(PVector g, boolean collide, boolean bounce, float d) {
    gravity = g;
    wallBounceOn = collide;
    collisionsOn = bounce;
    density = d;
    particles = new ArrayList<Particle>();
  }
  
  float getRadius(float mass, float density) {
    return sqrt(mass / (PI * density));
  }
  
  void addParticle(PVector position, PVector velocity, float mass) {
    particles.add(new Particle(position, velocity, gravity, mass, getRadius(mass, density), collisionsOn, wallBounceOn));
  }

  void run(float deltaTime) {
    update(deltaTime);
    display();
  }
  
  void display() {
    for (Particle p : particles) {
      p.show();
    }
  }
  
  
  void applyCollisions() {
    for (Particle p : particles) {
      if (p.hasCollided) {
        p.hasCollided = false;
      } else {
        for (Particle other : particles) {
          float intersectionDist = p.intersectionDist(other);
          if (! p.equals(other) && intersectionDist >= 0) {
            //float m1 = p.mass, m2 = other.mass;
            //float M = m1 + m2;
            //PVector v1i = p.velocity, v2i = other.velocity;
            //p.velocity = PVector.add(PVector.mult(v1i, (m1 - m2) / M), PVector.mult(v2i, 2 * m2 / M));
            //other.velocity = PVector.add(PVector.mult(v1i, 2 * m1 / M), PVector.mult(v2i, (m2 - m1) / M));
            
            PVector extraPos = PVector.sub(p.position, other.position).setMag(intersectionDist);
            //extraPos.mult(0.5);
            p.position.add(extraPos);
            other.position.add(extraPos.mult(-1));
            
            float angle = PVector.sub(p.position, other.position).heading();
            float v1 = p.velocity.mag() * elasticity;
            float v2 = other.velocity.mag() * elasticity;
            float diffA1 = atan2(p.velocity.y, p.velocity.x) - angle;
            float diffA2 = atan2(other.velocity.y, other.velocity.x) - angle;
            float vx1 = v1 * cos(diffA1);
            float vx2 = v2 * cos(diffA2);
            p.velocity.y = v1 * sin(diffA1);
            other.velocity.y = v2 * sin(diffA2);
            float totalM = p.mass + other.mass;
            float diffM = p.mass - other.mass;
            p.velocity.x = (diffM * vx1 + 2 * other.mass * vx2) / totalM;
            other.velocity.x = (-diffM * vx2 + 2 * p.mass * vx1) / totalM;
            p.velocity.rotate(angle);
            other.velocity.rotate(angle);
                        
            other.hasCollided = true;
            p.hasCollided = true;
          }
        }
      }
    }
  }
  
  void update(float deltaTime) {
    if (collisionsOn) {
      applyCollisions();
    }
    for (Particle p : particles) {
      p.advance(deltaTime);
    }
  }
  
  PVector forceToVelocity(PVector force, float duration, float mass) {
    return PVector.mult(force, duration / mass);
  }
  
  
  void addRandomParticles(int n, float minMass, float maxMass, boolean useForce, float minQ, float maxQ) {
    // typical force: 22956
    // typical velocity: 184
    particles.clear();
    for (int i = 0; i < n; i++) {
      float mass = random(minMass, maxMass);
      PVector velocity;
      if (useForce) {
        PVector appliedForce = PVector.random2D().setMag(random(minQ, maxQ));
        velocity = forceToVelocity(appliedForce, 1, mass);
      } else {
        velocity = PVector.random2D().setMag(random(minQ, maxQ));
      }
      addParticle(randomPosition(), velocity, mass);
    }
  }
  
  void addTwoCollidingParticles(float minMass, float maxMass, float initialVelocity) {
    particles.clear();
    // mass 50..200
    float m1 = random(minMass, maxMass);
    float r1 = getRadius(m1, density);
    float m2 = random(minMass, maxMass);
    float r2 = getRadius(m2, density);
    
    PVector pos1 = randomPosition();
    Particle p1 = new Particle(pos1, new PVector(0, 0), new PVector(0, 0), m1, r1, true, true);
    
    PVector pos2 = randomPosition();
    PVector v2 = PVector.sub(pos1, pos2);
    v2.setMag(initialVelocity);
    v2.rotate(PI / 80.0);
    Particle p2 = new Particle(pos2, v2, new PVector(0, 0), m2, r2, true, true);
    
    particles.add(p1);
    particles.add(p2);
  }
  
  PVector randomPosition() {
    return new PVector(random(width), random(height));
  }
  
}
