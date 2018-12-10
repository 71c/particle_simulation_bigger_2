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
  /* todo add elasticity */
  float elasticity = 1;
  
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
    stroke(255);
    float scale = 0.25;
    // TODO: if (visualizeVelocity)   
    line(position.x, height - position.y, position.x + velocity.x * scale, height - (position.y + velocity.y * scale));
    // TODO: if (visualizeAcceleration)
    line(position.x, height - position.y, position.x + acceleration.x * scale, height - (position.y + acceleration.y * scale));
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

    
    move(t);
  
  

  }
  
  // http://higuma.github.io/bouncing-balls/
  void move(float t) {
    boolean canAccelerateLeft = acceleration.x < 0 && position.x > radius;
    boolean canAccelerateRight = acceleration.x > 0 && position.x < width - radius;
    if (! wallBounceOn || canAccelerateLeft || canAccelerateRight) {
      velocity.x += acceleration.x * t;
    }
    position.x += velocity.x * t;
    
    if (wallBounceOn) {
      if (position.x < radius) {
        velocity.x = -velocity.x * elasticity;
        position.x = 2 * radius - position.x;
      } else if (position.x >= width - radius) {
        velocity.x = -velocity.x * elasticity;
        position.x = 2 * (width - radius) - position.x;
      }
    }
    
    boolean canAccelerateDown = acceleration.y < 0 && position.y > radius;
    boolean canAccelerateUp = acceleration.y > 0 && position.y < height - radius;
    if (! wallBounceOn || canAccelerateDown || canAccelerateUp) {
      velocity.y += acceleration.y * t;
    }
    position.y += velocity.y * t;
    
    if (wallBounceOn) {
      if (position.y >= height - radius) {
        velocity.y = -velocity.y * elasticity;
        position.y = 2 * (height - radius) - position.y;
      } else if (position.y < radius) {
        velocity.y = -velocity.y * elasticity;
        position.y = 2 * radius - position.y;
      }
    }
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
