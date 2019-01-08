// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector gravity;
  boolean wallBounceOn;
  boolean collisionsOn;
  float density;
  float elasticity = 1;
  boolean visualizeVelocity;
  boolean visualizeAcceleration;

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
    this(g, collide, bounce, 1.0, 0.5);
  }

  ParticleSystem(PVector g, boolean ballCollide, boolean wallBounce, float elasticity_, float d) {
    gravity = g;
    collisionsOn = ballCollide;
    wallBounceOn = wallBounce;
    elasticity = elasticity_;
    density = d;
    particles = new ArrayList<Particle>();
  }

  void setVisualizeVelocity(boolean b) {
    visualizeVelocity = b;
    for (Particle p : particles)
      p.visualizeVelocity = b;
  }

  void setVisualizeAcceleration(boolean b) {
    visualizeAcceleration = b;
    for (Particle p : particles)
      p.visualizeAcceleration = b;
  }

  void setCollisionsOn(boolean b) {
    collisionsOn = b;
    for (Particle p : particles)
      p.collisionsOn = b;
  }

  void setGravity(PVector g) {
    gravity = g;
    for (Particle p : particles) {
      p.setGravity(gravity);
    }
  }

  void setElasticity(float e) {
    elasticity = e;
    for (Particle p : particles)
      p.elasticity = e;
  }

  float getRadius(float mass, float density) {
    return sqrt(mass / (PI * density));
  }

  void addParticle(PVector position, PVector velocity, float mass) {
    particles.add(new Particle(position, velocity, gravity, mass, getRadius(mass, density), collisionsOn, wallBounceOn, elasticity, visualizeVelocity, visualizeAcceleration));
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
    for (Particle p1 : particles) {
      if (p1.hasCollided) {
        p1.hasCollided = false;
      } else {
        for (Particle p2 : particles) {
          if (p1.equals(p2)) {
            continue;
          }
          
          float intersectionDist = p1.intersectionDist(p2);
          if (intersectionDist >= 0) {
            PVector extraPos = PVector.sub(p1.position, p2.position).setMag(intersectionDist * 0.5);
            p1.position.add(extraPos);
            p2.position.add(extraPos.mult(-1));

            //float angle = PVector.sub(p1.position, p2.position).heading();
            //p1.velocity.rotate(-angle).mult(elasticity);
            //p2.velocity.rotate(-angle).mult(elasticity);
            //float vx1 = p1.velocity.x;
            //float vx2 = p2.velocity.x;
            //float totalM = p1.mass + p2.mass;
            //float diffM = p1.mass - p2.mass;
            //p1.velocity.x = (diffM * vx1 + 2 * p2.mass * vx2) / totalM;
            //p2.velocity.x = (-diffM * vx2 + 2 * p1.mass * vx1) / totalM;
            //p1.velocity.rotate(angle);
            //p2.velocity.rotate(angle);
            
            float angle = PVector.sub(p1.position, p2.position).heading();
            p1.velocity.rotate(-angle);
            p2.velocity.rotate(-angle);
            float vx1 = p1.velocity.x;
            float vx2 = p2.velocity.x;
            float totalM = p1.mass + p2.mass;
            float diffM = p1.mass - p2.mass;
            float vx1E = (diffM * vx1 + 2 * p2.mass * vx2) / totalM;
            float vx2E = (-diffM * vx2 + 2 * p1.mass * vx1) / totalM;
            float vxI  = (p1.mass * vx1 + p2.mass * vx2) / totalM;
            p1.velocity.x = vx1E * elasticity + vxI * (1 - elasticity);
            p2.velocity.x = vx2E * elasticity + vxI * (1 - elasticity);
            p1.velocity.rotate(angle);
            p2.velocity.rotate(angle);
            
            p2.hasCollided = true;
            p1.hasCollided = true;
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
    Particle p1 = new Particle(pos1, new PVector(0, 0), new PVector(0, 0), m1, r1, collisionsOn, wallBounceOn, elasticity, visualizeVelocity, visualizeAcceleration);

    PVector pos2 = randomPosition();
    PVector v2 = PVector.sub(pos1, pos2);
    v2.setMag(initialVelocity);
    //v2.rotate(PI / 80.0);
    Particle p2 = new Particle(pos2, v2, new PVector(0, 0), m2, r2, collisionsOn, wallBounceOn, elasticity, visualizeVelocity, visualizeAcceleration);

    particles.add(p1);
    particles.add(p2);
  }

  PVector randomPosition() {
    return new PVector(random(width), random(height));
  }
}
