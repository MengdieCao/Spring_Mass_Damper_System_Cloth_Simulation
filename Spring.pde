class Spring{
  float restDist;
  Particle p1, p2;
  float springC = 0.8;
  float dampingC = 0.2;
  PVector prevM, newM;
  float s, t;
  PVector q1, q2;
  
  Spring(Particle p1, Particle p2){
    this.p1 = p1;
    this.p2 = p2;
    restDist = p1.getPos().dist(p2.getPos());
  }
  
  void springDamping(){
    PVector uij = p2.getPos().copy().sub(p1.getPos().copy());
    float currDist = uij.mag();
    uij.normalize();
    PVector springForce1 = uij.copy().mult(springC*(currDist-restDist));
    PVector springForce2 = springForce1.copy().mult(-1);
    PVector dampingForce1 = uij.copy().mult(uij.dot(p2.getVel().copy()
      .sub(p1.getVel().copy()))*dampingC);
    PVector dampingForce2 = dampingForce1.copy().mult(-1);
    p1.addForce(springForce1);
    p1.addForce(dampingForce1);
    p2.addForce(springForce2);
    p2.addForce(dampingForce2);
  }
  
  PVector calculateM(PVector q1, PVector q2){
    this.q1 = q1;
    this.q2 = q2;
    PVector a = p2.pos.copy().sub(p1.pos.copy());
    PVector b = q2.copy().sub(q1.copy());
    PVector norm = a.copy().cross(b.copy());
    norm.normalize();
    PVector m = new PVector();
    PVector r = q1.copy().sub(p1.pos.copy());
    float sTop = r.copy().dot(b.copy().normalize().cross(norm.copy()));
    float sBot = a.copy().dot(b.copy().normalize().cross(norm.copy()));
    s = sTop/sBot;
    float tTop = r.copy().dot(a.copy().normalize().cross(norm.copy()));
    tTop = tTop*(-1);
    float tBot = b.copy().dot(a.copy().normalize().cross(norm.copy()));
    t = tTop/tBot;
    if (s >=0 && s <= 1 && t>=0 && t<=1){
    PVector pA = p1.pos.copy().add(a.copy().mult(s));
    PVector qA = q1.copy().add(b.copy().mult(t));
    m = qA.copy().sub(pA);
    }
    return m;
  }
  
  void edgeEdgeResponse(){
    PVector lineDirection = q2.copy().sub(q1);
    lineDirection.normalize();
    p1.vel = lineDirection.copy().sub(p1.vel.copy().normalize()).mult(p1.vel.mag());
    p2.vel = lineDirection.copy().sub(p2.vel.copy().normalize()).mult(p2.vel.mag());
    //p2.vel = p2.vel.mult(-1);
  }
  
}