class Polygon{
  Particle p1, p2, p3;
  PVector vertex1, vertex2, vertex3,vertex4;
  PVector normal;
  PVector[]projectionVertices = new PVector[3];
  int axisMostAkinToNormal;
  PVector avgVel;
  PVector relativeVel;
  Polygon(Particle p1, Particle p2, Particle p3){
    this.p1 = p1;
    this.p2 = p2;
    this.p3 = p3;
    updatePolygon();
 }
 
 void updatePolygon(){
   vertex1 = p1.pos.copy();
    vertex2 = p2.pos.copy();
    vertex3 = p3.pos.copy();
    avgVel = p1.vel.copy().add(p2.vel.copy().add(p3.vel.copy())).div(3);
    normal = calcTriNorm(p1,p2,p3);
    float nx=abs(normal.x);    //three elements of the normal
    float ny=abs(normal.y);
    float nz=abs(normal.z);
    if(nx>=ny && nx>=nz){
      axisMostAkinToNormal=1;    //x axis
    }else if(ny>=nx && ny>=nz){
      axisMostAkinToNormal=2;    //y axis
    }else{
      axisMostAkinToNormal=3;    //z axis
    }
    
    projectionVertices[0]=getProjectionCoord(vertex1);
    projectionVertices[1]=getProjectionCoord(vertex2);
    projectionVertices[2]=getProjectionCoord(vertex3);
 }
 
 PVector calcTriNorm(Particle p1, Particle p2, Particle p3) {
    PVector pos1 = p1.getPos().copy();
    PVector pos2 = p2.getPos().copy();
    PVector pos3 = p3.getPos().copy();
    PVector v1 = pos2.sub(pos1);
    PVector v2 = pos3.sub(pos1);
    return v1.cross(v2).normalize();
  }
  
  PVector getProjectionCoord(PVector loc){
    switch(axisMostAkinToNormal){
      case 1:
      return new PVector(loc.y,loc.z);
            
      case 2:
      return new PVector(loc.z,loc.x);
      
      case 3:
      return new PVector(loc.x,loc.y);

    }
    
    return new PVector(0,0,0);
  }
  
  //For a stationary object, I assume polygon is not moving, and assign a relative velocity 
  //to the object. For moving object, just add -avgVel to velocity of the object.
  PVector hittingPoint(Ball ball){
    updatePolygon();
    relativeVel = avgVel.copy().mult(-1).add(ball.spd);
    float tHit=(PVector.sub(vertex1,PVector.sub(ball.loc,relativeVel.copy())).dot(normal))/
    (relativeVel.copy().dot(normal));
    
    PVector hitPoint=PVector.mult(relativeVel,tHit);
    hitPoint.add(PVector.sub(ball.loc,relativeVel.copy().add(relativeVel)));
    return hitPoint;
  }
  
  boolean insidePolygon(PVector one){      //note "one" shall be the projection of X
    float lastEdge=determinant(PVector.sub(projectionVertices[0],projectionVertices[2]),
    PVector.sub(one,projectionVertices[2]));
    //println("start");
    //println("lastEdge "+lastEdge);
        
    for(int i=0;i<2;i++){
      float value_i=determinant(PVector.sub(projectionVertices[i+1],projectionVertices[i]),PVector.sub(one,projectionVertices[i]));
      //println(i+" :"+value_i);
      if(lastEdge*value_i<0){
        return false;
      }
    }
    return true;
  }
  
  float determinant(PVector edge,PVector towardsX){
    return edge.x*towardsX.y-edge.y*towardsX.x;
  }
  
  boolean hitPlane(Ball ball){
    updatePolygon();
    relativeVel = avgVel.copy().mult(-1).add(ball.spd);
    if(distanceToParticle(ball.loc)*distanceToParticle(
      PVector.sub(ball.loc,relativeVel))<0){
      return true;
    }else{
      return false;
    }
  }
  
  float distanceToParticle(PVector loc){
    return PVector.sub(loc,vertex1).dot(normal);
  }
 
  boolean sameDirectionWithNormal(PVector speed){
    if(speed.dot(normal)>0){
      return true;
    }
    return false;
  }
  
  
}