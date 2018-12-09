// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector gravity;
  boolean wallBounceOn;
  boolean collisionsOn;
  float density;
  
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
    particles.add(new Particle(position, velocity, gravity, mass, getRadius(mass, density), collisionsOn));
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
    Particle p1 = new Particle(pos1, new PVector(0, 0), new PVector(0, 0), r1, m1, true);
    
    PVector pos2 = randomPosition();
    PVector v2 = PVector.sub(pos1, pos2);
    v2.setMag(initialVelocity);
    Particle p2 = new Particle(pos2, v2, new PVector(0, 0), r2, m2, true);
    
    particles.add(p1);
    particles.add(p2);
  }
  
  PVector randomPosition() {
    return new PVector(random(width), random(height));
  }
  
}
