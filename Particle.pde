
class Particle {
  PVector pos;
  PVector prevPos;
  PVector vel;
  PVector prevVel;
  PVector acce;
  PVector accumulatedNorm;
  float mass;
  boolean movable;
  float h = 0.6;//0.5//0.6;
  PVector P1, P2, P3, P4, V1, V2, V3, V4, A1, A2, A3, A4;
  PVector prevM, m;

  Particle(PVector pos) {
    this.pos = pos;
    prevPos = pos;
    vel = new PVector(0, 0, 0);
    prevVel = new PVector(0, 0, 0);
    acce = new PVector(0, 0, 0);
    mass = 1;
    movable = true;
    accumulatedNorm = new PVector(0, 0, 0);
  }

  //add force implicitly through acceleration
  void addForce(PVector force) {
    acce.add(force.copy().div(mass));
  }

  //Euler integration
  void euler() {
    if (movable) {
      prevVel = vel.copy();
      prevPos = pos.copy();
      vel.add(acce.copy().mult(h));
      pos.add(vel.copy().mult(h));
      resetAcce();
    }
  }

 

  //Runge-Kutta Routine with 4 steps
  void RKPass1() {
    if (movable) {
      A1 = acce.copy();
      prevVel = vel.copy();
      prevPos = pos.copy();
      V1 = A1.copy().mult(h); 
      //println(V1.x+","+V1.y);
      vel.add(V1.copy().div(2)); 
      //println(vel.x+","+vel.y);
      P1 = vel.copy().mult(h);
      pos = pos.add(P1.copy().div(2));
      resetAcce();
    }
    //acce = new PVector(0,0,0); //reset
  }

  void RKPass2() {
    if (movable) {
      vel = prevVel.copy();
      pos = prevPos.copy();
      A2 = acce.copy();
      V2 = A2.copy().mult(h);
      vel = vel.add(V2.copy().div(2));
      P2 = vel.copy().mult(h);
      pos = pos.add(P2.copy().div(2));
      resetAcce();
    }
    
  }

  void RKPass3() {
    if (movable) {
      A3 = acce.copy();
      vel = prevVel.copy();
      pos = prevPos.copy();
      V3 = A3.copy().mult(h);
      //vel = vel.add((A1.copy()).add(A2.copy().mult(4).add(A3.copy())).div(6));
      vel = vel.add(V1.copy().add(V2.copy().mult(4).add(V3.copy())).div(6));
      //vel = vel.add(V3.copy().div(2));
      P3 = vel.copy().mult(h);
      //pos = pos.add(P3.copy().div(2));     
      pos = pos.add(P1.copy().add(P2.copy().mult(4).add(P3.copy())).div(6));
      resetAcce();
      //resetEverything();
    }
  }

  void RKPass4() {
    if (movable) {
      A4 = acce.copy();
      vel = prevVel.copy();
      pos = prevPos.copy();
      V4 = A4.copy().mult(h);
      //vel = vel.add((A1.copy()).add(A2.copy().mult(4).add(A3.copy())).div(6));
      vel = vel.add(V1.copy().add(V2.copy().mult(2).add(V3.copy().mult(2).add(V4.copy()))).div(6));
      //vel = vel.add(V3.copy().div(2));
      P4 = vel.copy().mult(h);
      //pos = pos.add(P3.copy().div(2));     
      pos = pos.add(P1.copy().add(P2.copy().mult(2).add(P3.copy().mult(2).add(P4.copy()))).div(6));
      resetAcce();
    }
    //posComp = new PVector(0,0,0);
  }


  PVector getPos() {
    return pos;
  }

  void resetAcce() {
    acce = new PVector(0, 0, 0);
  }

  void offsetPos(PVector v) {
    if (movable) {
      pos.add(v);
    }
  }

  void makeUnmovable() {
    movable = false;
  }

  void addToNormal(PVector normal) {
    accumulatedNorm.add(normal.normalize());
  }

  PVector getNorm() {
    return accumulatedNorm;
  }

  void resetNorm() {
    accumulatedNorm = new PVector(0, 0, 0);
  }

  PVector getVel() {
    return vel;
  }
}