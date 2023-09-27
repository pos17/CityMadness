
class ChaoticParticle{ // Particelle caotiche
  PVector p;
  PVector velocity;
  PVector acc; 
  Boolean state; 
  float maxspeed;
  float maxforce;
  float mass;
  
  ChaoticParticle(PVector velocity, PVector acc){
    this.state = false;
    this.p = new PVector(random(-width/2,width/2),random(-height/2,height/2)); 
    this.velocity = velocity;
    this.acc = acc;
    this.maxspeed = 5;
    this.maxforce = 40;
    this.mass = 1;
  }
  ChaoticParticle(PVector p,PVector velocity, PVector acc){
    this.state = false;
    this.p = p;
    this.velocity = velocity;
    this.acc = acc;
    this.maxspeed = 5;
    this.maxforce = 40;
    this.mass = 1;
  }
  
  ChaoticParticle(float x, float y,PVector velocity, PVector acc){
    this.state = false;
    this.p = new PVector(x,y);
    this.velocity = velocity;
    this.acc = acc;
    this.maxspeed = 5;
    this.maxforce = 40;
    this.mass = 1;
  }
  void applyForce(PVector force) {
    PVector f = PVector.div(force,mass);  // Force/Mass
    this.acc.add(f);
  }
  PVector getPos(){
    return this.p; 
  }
  
  PVector getVel() {
    return this.velocity;
  }
  PVector getAcc() {
    return this.acc;
  }
  
  void addVel(PVector acc) {
    
  }
  
  void setState(Boolean aState) {
    this.state = aState;
  }
  
  
  void moveNoise(){
    if(this.state == false)
      this.p.add((this.p.cross(PVector.fromAngle((noise(this.p.x/100, this.p.y/100, float(frameCount)/100)-0.5)*TWO_PI))).setMag(2));
    else{
      this.p.add((this.p.cross(PVector.fromAngle((noise(this.p.x/100, this.p.y/100, float(frameCount)/100)-0.5)*TWO_PI))).setMag(3));
      // Update velocity
      this.velocity.add(acc);
      // Limit speed
      this.velocity.limit(maxspeed);
      this.p.add(velocity);
      // Reset accelertion to 0 each cycle
      this.acc.mult(0);
    }
  }
  
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target,this.p);  // A vector pointing from the location to the target
    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);
    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }
  float getDist(PVector target) {
    return this.p.dist(target);
  }
}
