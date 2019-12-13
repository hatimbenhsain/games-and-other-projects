class Thread{

	Body body;

	int thickness;
	float x,y;
	float len;
	float dist;
	Spider theSpider;

	float mod;

	DistanceJoint dj;

	boolean hacked;

	Thread(Spider sp){
		thickness=1;
		x=width/2+1;
		y=-height/2;
		len=height*3/4;
		dist=0.0;
		mod=0.0;

		hacked=false;

		theSpider=sp;

		BodyDef bd=new BodyDef();									//the thread's body is just a circle shape offscreen, the actual 
		bd.type=BodyType.KINEMATIC;									//thread is just a line connecting the two.
		bd.position.set(box2d.coordPixelsToWorld(new Vec2(x,y)));
		body=box2d.createBody(bd);

		CircleShape cs=new CircleShape();
		cs.m_radius=box2d.scalarPixelsToWorld(1);
		body.createFixture(cs,1.0);

		DistanceJointDef djd=new DistanceJointDef();

		Vec2 localAnchor=theSpider.body.getWorldCenter();

		djd.initialize(body,theSpider.body,body.getWorldCenter(),localAnchor);
		djd.length=box2d.scalarPixelsToWorld(len);
		djd.frequencyHz=2;
		djd.dampingRatio=1;

		dj=(DistanceJoint) box2d.createJoint(djd);					//distance joint between the anchor point and the spider.
	}

	void display(){
		stroke(255);
		strokeWeight(thickness);
		pushMatrix();
		translate(-worldX,-worldY);
		if(hacked==false){
			line(x,y,theSpider.currentPos().x,theSpider.currentPos().y);
		}else{														//animation for when the thread is hacked. it gets progressively shorter.
			dist+=10;
			Vec2 v=theSpider.currentPos().sub(new Vec2(x,y));
			v.normalize();
			v=v.mul(dist);
			v=theSpider.currentPos().sub(v);
			line(x,y,v.x,v.y);
		}
		popMatrix();
	}

	void hack(){													//destroying the thread.
		hacked=true;
		box2d.destroyBody(body);
		spider.idle=false;
	}

}