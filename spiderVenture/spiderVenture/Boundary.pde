// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

class Boundary {              //code taken from Daniel Shiffman, didn't modify much
  float x;
  float y;
  float w;
  float h;
  int c;
  Body b;

 Boundary(float x_,float y_, float w_, float h_, float a) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;

    c=255;
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    sd.setAsBox(box2dW, box2dH);
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.angle = a;
    bd.position.set(box2d.coordPixelsToWorld(x,y));
    b = box2d.createBody(bd);
    b.createFixture(sd,1);
  }
  void display() {
    if(worldY>height*4){
      c=int(map(height*4.2-worldY,0,height*0.2,0,255));     //  toward the end of the first section, the boundaries disappear
      if(c>255){                                            //by decrementing the color
        c=255;
      }
      if(c<0){
        c=0;
      }
    }
    fill(c);
    noStroke();
    rectMode(CENTER);
    float a = b.getAngle();
    pushMatrix();
    translate(x,y);
    rotate(-a);
    translate(-worldX,-worldY);
    rect(0,0,w,h);
    popMatrix();
  }

}

