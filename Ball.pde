class Ball{
  PVector acceleration;
  PVector loc;
  PVector spd;
  PVector prevSpd;
  int lifeSpan=200;
  PVector currColor = new PVector(0,0,255);
  Ball(PVector location, PVector speed) {
    this.loc=new PVector(location.x, location.y, location.z);
    this.spd=new PVector(speed.x, speed.y, speed.z);
    //this.acceleration = gravity.copy();
  }

  void update() {
    lifeSpan--;
    if (prevSpd != null) {
      spd = prevSpd.copy();
    }
    spd.add(gravity);
    loc.add(spd);
    checkPlanes(cloth.polygons);
  }

  

  

  boolean isDead() {
    if (lifeSpan<0) {
      return true;
    }
    return false;
  }

  void checkPlanes(ArrayList<Polygon> polygons) {
    for (int i=0; i<polygons.size(); i++) {
      Polygon currPoly = polygons.get(i);
      if (detectCollision(currPoly)) {
        
        bounce(currPoly.normal.copy().normalize());
      }
    }
  }

  boolean detectCollision(Polygon plane) {
    //println(plane.avgVel.x+","+plane.avgVel.y+","+plane.avgVel.z);
    if (plane.hitPlane(this)) {
      //println(spd);
      //println("!!!!!");
      PVector hittingPoint=plane.hittingPoint(this);
      
      PVector projCoord=plane.getProjectionCoord(hittingPoint);
      if (plane.insidePolygon(projCoord)) {

        return true;
      }
    }
    return false;
  }



  void bounce(PVector normal) {
    //println(spd);
    currColor = new PVector(0,128,0);
    ////println(",,,");
    loc.sub(spd);
    PVector vn=PVector.mult(normal, spd.dot(normal));
    PVector vt=PVector.sub(spd, vn);
    //println(normal);
    vn.mult(-cr);
    vt.mult(1-cf);    
    spd=PVector.add(vn, vt);   
    ////spd.mult(-1);
    loc.add(spd);
    //println(spd);
    //currColor = new PVector(0,128,0);
    //float angle = PVector.angleBetween(spd,normal);
    //spd.mult(-1);
    //spd.add(gravity);
    //loc.add(spd);
  }


  void display() {
    stroke(currColor.x,currColor.y,currColor.z);
    strokeWeight(6);
    point(loc.x, loc.y, loc.z);
  }

  
  
}