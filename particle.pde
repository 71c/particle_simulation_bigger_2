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
  float elasticity;
  boolean visualizeVelocity = false;
  boolean visualizeAcceleration = false;


  public Particle(PVector position, PVector velocity, PVector gravity, float mass, float radius) {
    this(position, velocity, gravity, mass, radius, false);
  }

  public Particle(PVector position, PVector velocity, PVector gravity, float mass, float radius, boolean collisionsOn) {
    this(position, velocity, gravity, mass, radius, collisionsOn, true, 1.0);
  }

  public Particle(PVector position, PVector velocity, PVector gravity, float mass, float radius, boolean collisionsOn, boolean wallBounceOn, float elasticity) {
    this(position, velocity, gravity, mass, radius, collisionsOn, wallBounceOn, elasticity, false, false);
  }

  public Particle(PVector position, PVector velocity, PVector gravity, float mass, float radius, boolean collisionsOn, boolean wallBounceOn, float elasticity, boolean visualizeVelocity_, boolean visualizeAcceleration_) {
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
    this.elasticity = elasticity;
    visualizeVelocity = visualizeVelocity_;
    visualizeAcceleration = visualizeAcceleration_;
    hasCollided = false;
  }

  void setGravity(PVector newG) {
    applyForce(PVector.mult(gravity, -mass));
    gravity = newG;
    applyForce(PVector.mult(gravity, mass));
  }

  public PVector getPosition() {
    return position;
  }

  void show() {
    fill(255);
    stroke(255);
    ellipse(position.x, height - position.y, radius, radius);

    float scale = 0.25;

    if (visualizeVelocity && velocity.mag() != 0) {
      fill(255, 0, 0);
      stroke(255, 0, 0);
      vecArrow(position, velocity, scale);
    }
    if (visualizeAcceleration && acceleration.mag() != 0) {
      fill(0, 255, 0);
      stroke(0, 255, 0);
      vecArrow(position, acceleration, scale);
    }
  }

  void vecArrow(PVector startPos, PVector vec, float scaleFactor) {
    float x1 = startPos.x, 
      y1 = height - startPos.y, 
      x2 = startPos.x + vec.x * scaleFactor, 
      y2 = height - (startPos.y + vec.y * scaleFactor);
    arrow(x1, y1, x2, y2);
  }

  void arrow(float x1, float y1, float x2, float y2) {
    line(x1, y1, x2, y2);
    pushMatrix();
    translate(x2, y2);
    float a = atan2(x1-x2, y2-y1);
    rotate(a);
    //line(0, 0, -10, -10);
    //line(0, 0, 10, -10);
    triangle(0, 0, -5, -10, 5, -10);
    popMatrix();
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

    // x part. Same thing done for y
    if (wallBounceOn) {
      if (position.x < radius) {
        // bounce by flipping velocity x. dampen by elasticity
        velocity.x = -velocity.x * elasticity;
        // this works like magic. found it in code of a similar physics simulator
        position.x = 2 * radius - position.x;
      } else if (position.x >= width - radius) { // same thing but on the other side of the wall
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
