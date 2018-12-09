class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector gravity;
  float radius;
  float mass;
  boolean wallBounceOn;
  boolean collisionsOn;
  boolean hasCollided;
  float time;
  ArrayList<PVector> forceQueue;
  ArrayList<Float> forceQueueTimes;
  PVector netForce;
  
  public Particle(PVector position, PVector velocity, PVector gravity, float mass, float radius) {
    this(position, velocity, gravity, mass, radius, false);
  }
  
  public Particle(PVector position, PVector velocity, PVector gravity, float mass, float radius, boolean collisionsOn) {
    this(position, velocity, gravity, mass, radius, collisionsOn, true);
  }
  
  public Particle(PVector position, PVector velocity, PVector gravity, float mass, float radius, boolean collisionsOn, boolean wallBounceOn) {
    netForce = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    time = 0;
    forceQueue = new ArrayList<PVector>();
    forceQueueTimes = new ArrayList<Float>();
    
    this.position = position;
    this.velocity = velocity;
    
    this.gravity = gravity;
    this.radius = radius;
    this.mass = mass;
    applyForce(PVector.mult(gravity, mass));
    this.wallBounceOn = wallBounceOn;
    this.collisionsOn = collisionsOn;
    hasCollided = false;
  }
  
  public PVector getPosition() {
    return position;
  }
  
  void show() {
    ellipse(position.x, height - position.y, radius, radius);
  }
  
  void advance(float t) {
    time += t;
    
    if (forceQueueTimes.size() >= 1) {
      int i = 0;
      while (i < forceQueueTimes.size()) {
        if (time >= forceQueueTimes.get(i)) {
          applyForce(forceQueue.remove(i));
          forceQueueTimes.remove(i);
          continue;
        }
        i++;
      }
    }
    
    if (wallBounceOn) {
      if (position.x + radius >= width || position.x - radius <= 0) {
        velocity.x = -velocity.x;
      } else if (position.y + radius >= height || position.y - radius <= 0) {
        velocity.y = -velocity.y;
      }
      position.x = constrain(position.x, radius, width - radius);
      position.y = constrain(position.y, radius, height - radius);
    }
    
    PVector halfDeltaV = PVector.mult(acceleration, t * 0.5);
    velocity.add(halfDeltaV);
    position.add(PVector.mult(velocity, t));
    velocity.add(halfDeltaV);
  }
  
  void applyForce(PVector appliedForce) {
    netForce.add(appliedForce);
    acceleration = PVector.div(netForce, mass);
  }
  
  void applyTimedForce(PVector appliedForce, float duration) {
    applyForce(appliedForce);
    forceQueue.add(PVector.mult(appliedForce, -1));
    forceQueueTimes.add(time + duration);
  }
  
  float intersectionDist(Particle other) {
    return -position.dist(other.position) + radius + other.radius;
  }
  
  boolean intersects(Particle other) {
    float distance = intersectionDist(other);
    return distance >= 0;
  }
  
}
