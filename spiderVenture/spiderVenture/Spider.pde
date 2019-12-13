class Spider{

	Body body;
	Body[] legs;
	Body[] legs2;
	RevoluteJoint[] joints;
	RevoluteJoint[] joints2;
	float x,y;
	float w;
	float legW, legH;
	float newLegH;
	float unitAngle;
	Vec2[] vertices;
	float unit;
	float motorSpeed;
	float xoff;

	float dens;

	int walkCount=0;

	boolean idle=true;

	boolean dead=false;

	Vec2 wind;


	Spider(float x_,float y_,float d){				//builder
		wind=new Vec2(0,0);
		dens=d;
		unit=5;
		x=x_;
		y=y_;
		w=unit*4;
		legW=unit/4;
		legH=unit*7;
		newLegH=legH*3;
		unitAngle=PI/16;
		motorSpeed=PI;
		xoff=0.0;
		makeBody(new Vec2(x,y),w);
	}

	void makeBody(Vec2 center, float w_){			//makes the main body, fixture, etc
		BodyDef bd=new BodyDef();
		bd.type=BodyType.DYNAMIC;
		bd.position.set(box2d.coordPixelsToWorld(new Vec2(x,y)));
		body=box2d.createBody(bd);

		vertices=new Vec2[4];
		vertices[0]=box2d.vectorPixelsToWorld(new Vec2(-unit*2,unit));
		vertices[1]=box2d.vectorPixelsToWorld(new Vec2(-unit,-unit));
		vertices[2]=box2d.vectorPixelsToWorld(new Vec2(unit,-unit));
		vertices[3]=box2d.vectorPixelsToWorld(new Vec2(unit*2,unit));

		PolygonShape ps=new PolygonShape();
		ps.set(vertices,vertices.length);


		FixtureDef fd=new FixtureDef();
		fd.shape=ps;
		fd.density=dens;
		fd.friction=1.0;
		fd.restitution=0;

		body.createFixture(fd);

		legs=new Body[6];											//legs is the part of the leg connected to the body
		legs2=new Body[6];											//legs2 is the part connected to legs
		joints=new RevoluteJoint[6];
		joints2=new RevoluteJoint[6];

		for(int i=0;i<3;i++){										//the three legs on the right of the spider
			legs[i]=makeLeg(5*PI/8+(unitAngle)*(i),i);
		}
		for(int i=0;i<3;i++){										//the three legs on the left of the spider
			legs[i+3]=makeLeg(-5*PI/8-(unitAngle)*(i),i+3);
		}
	}

	void display(){													//displaying the spider
		Vec2 pos=box2d.getBodyPixelCoord(body);
		float a=body.getAngle();

		Fixture f=body.getFixtureList();

		PolygonShape ps=(PolygonShape) f.getShape();

		rectMode(CENTER);
		pushMatrix();
		translate(pos.x,pos.y);
		translate(-worldX,-worldY);
		rotate(-a);
		fill(255);
		noStroke();
		beginShape();
		for(int i=0;i<ps.getVertexCount();i++){
			Vec2 v=box2d.vectorWorldToPixels(ps.getVertex(i));
			vertex(v.x,v.y);
		}
		endShape(CLOSE);
		popMatrix();

		displayLegs();
	}

	Vec2 getVertex(int i){									//get one of the body's vertice
		Fixture f=body.getFixtureList();
		PolygonShape ps=(PolygonShape) f.getShape();
		return box2d.vectorWorldToPixels(ps.getVertex(i));
	}

	Vec2 currentPos(){										//returns the center of the body in pixels
		return box2d.getBodyPixelCoord(body);
	}

	void displayLegs(){										//displays all the leg parts
		Vec2 pos;

		for(int i=0;i<legs.length;i++){
			pushMatrix();
			pos=box2d.getBodyPixelCoord(legs[i]);
			translate(pos.x,pos.y);
			translate(-worldX,-worldY);
			rotate(-legs[i].getAngle());
			rectMode(CENTER);
			rect(0,0,legW,legH);
			popMatrix();
			pushMatrix();
			pos=box2d.getBodyPixelCoord(legs2[i]);
			translate(pos.x,pos.y);
			translate(-worldX,-worldY);
			rotate(-legs2[i].getAngle());
			rectMode(CENTER);
			rect(0,0,legW,newLegH);
			popMatrix();			
		}
	}

	Body makeLeg(float ang,int i){

		//leg 1

		BodyDef bd=new BodyDef();
		bd.type=BodyType.DYNAMIC;
		Vec2 pos;
		Vec2 offset;
		pos=body.getPosition();
		bd.position.set(pos);
		Body legBody=box2d.createBody(bd);

		PolygonShape ps=new PolygonShape();
		float box2dW=box2d.scalarPixelsToWorld(legW);
		float box2dH=box2d.scalarPixelsToWorld(legH/2);
		ps.setAsBox(box2dW,box2dH);

		FixtureDef fd=new FixtureDef();
		fd.shape=ps;
		fd.density=dens;
		fd.friction=0.3;
		fd.restitution=0;
		fd.filter.categoryBits=0x0004;
		fd.filter.maskBits=0xFFFF & ~ 0x0004;

		legBody.createFixture(fd);
		PVector temp=new PVector(0,legH/2);
		temp.rotate(-ang);
		offset=box2d.vectorPixelsToWorld(new Vec2(temp.x,temp.y));
		legBody.setTransform(body.getWorldCenter().add(offset),ang);

		RevoluteJointDef rjd = new RevoluteJointDef();
		rjd.initialize(body,legBody,body.getWorldCenter());
		rjd.enableLimit=true;

		if(i<3){													//the limit of the angular movement is different for every leg
			rjd.lowerAngle=-unitAngle*(i%3);
			rjd.upperAngle=unitAngle*(2-(i%3));
		}else if(i>=3){
			rjd.lowerAngle=-unitAngle*(2-(i%3));
			rjd.upperAngle=unitAngle*(i%3);			
		}

		rjd.motorSpeed=motorSpeed;
		rjd.maxMotorTorque=1000.0;
		rjd.enableMotor=false;

		RevoluteJoint joint=(RevoluteJoint) box2d.world.createJoint(rjd);	//the joint connecting the body to the leg

		joints[i]=joint;

		//leg 2

		pos=legBody.getPosition();
		temp=new PVector(0,legH/2);
		temp.rotate(-ang);
		offset=box2d.vectorPixelsToWorld(new Vec2(temp.x,temp.y));
		pos=pos.add(offset);
		Vec2 origin=pos;

		float legH2, dH;
		float newAng;
		dH=w*4;
		legH2=dH+legH*sin(ang-PI/2);
		newAng=acos(legH2/newLegH);

		if(i>=3){newAng=-newAng;}											//the angle of rotation is different depending on which side of the body
																			//the leg is on
		temp=new PVector(0,newLegH/2);
		temp.rotate(-newAng);
		offset=box2d.vectorPixelsToWorld(new Vec2(temp.x,temp.y));
		pos=pos.add(offset);

		bd=new BodyDef();
		bd.type=BodyType.DYNAMIC;
		bd.position.set(pos);
		Body legBody2=box2d.createBody(bd);

		ps=new PolygonShape();
		box2dW=box2d.scalarPixelsToWorld(legW);
		box2dH=box2d.scalarPixelsToWorld(newLegH/2);
		ps.setAsBox(box2dW,box2dH);

		fd=new FixtureDef();
		fd.shape=ps;
		fd.density=dens;
		fd.friction=1.0;
		fd.restitution=0;
		fd.filter.categoryBits=0x0004;
		fd.filter.maskBits=0xFFFF & ~ 0x0004;

		legBody2.createFixture(fd);
		legBody2.setTransform(legBody2.getWorldCenter(),newAng);

		rjd = new RevoluteJointDef();
		rjd.initialize(legBody,legBody2,origin);
		rjd.enableLimit=true;
		rjd.lowerAngle=-PI/4;
		rjd.upperAngle=PI/4;

		rjd.motorSpeed=motorSpeed;
		rjd.maxMotorTorque=1000.0;
		rjd.enableMotor=false;

		// if(i<3){
		// 	rjd.motorSpeed=motorSpeed;
		// }

		RevoluteJoint joint2=(RevoluteJoint) box2d.world.createJoint(rjd);		//joint connecting the two parts of the leg together

		joints2[i]=joint2;


		legs2[i]=legBody2;

		return(legBody);
	}

	void moveRight(int i){														//enables the motor of one pair of legs
		joints[2-i].enableMotor(true);
		joints[i+3].enableMotor(true);
		joints2[2-i].enableMotor(true);
		joints2[i+3].enableMotor(true);
	}

	void stopMovement(int i){													//stops the motor of one pair of legs
		joints[2-i].enableMotor(false);
		joints[i+3].enableMotor(false);
		joints2[2-i].enableMotor(false);
		joints2[i+3].enableMotor(false);
	}

	void stopAllMovement(){														//stops the motor of all lags
		for(RevoluteJoint joint : joints){
			joint.enableMotor(false);
		}
		for(RevoluteJoint joint : joints2){
			joint.enableMotor(false);
		}
	}

	void killBody(){															//destroys the spider
		box2d.destroyBody(body);
		for(RevoluteJoint joint : joints2){
			box2d.destroyBody(joint.getBodyA());
			box2d.destroyBody(joint.getBodyB());
		}
	}

	void lock(int i){															//locks the motor of one pair of legs to its current position
		joints2[2-i].setLimits(0,0);
		joints2[i+3].setLimits(0,0);
	}

	void restore(int i){														//unlocks one pair of legs
		joints2[2-i].setLimits(-PI/4,PI/4);
		joints2[i+3].setLimits(-PI/4,PI/4);
		joints[i+3].setMotorSpeed(motorSpeed);
		joints2[i+3].setMotorSpeed(motorSpeed);
		joints[2-i].setMotorSpeed(motorSpeed);
		joints[2-i].setMotorSpeed(motorSpeed);
	}

	void restoreAll(){															//unlocks all legs
		for(int i=0;i<6;i++){
			joints[i].setLimits(-PI/4,PI/4);
			joints[i].setMotorSpeed(motorSpeed);
			joints2[i].setLimits(-PI/4,PI/4);
			joints2[i].setMotorSpeed(motorSpeed);
		}
	}

	void goForward(){															//an attempt to automate the walk cycle
		int k=8;																//clumsy but works sometimes. every pair is 
		int waitTime=2;															//respectively activated for 8 frames and paused 
		if(walkCount<k){														//for 2 frames.
			restore(0);
			lock(1);
			lock(2);
			moveRight(0);
		}else if(walkCount<k+waitTime){
			stopAllMovement();
		}else if(walkCount<k*2+waitTime){
			restore(1);
			lock(0);
			lock(2);
			moveRight(1);
		}else if(walkCount<k*2+waitTime*2){
			stopAllMovement();
		}else if(walkCount<k*3+waitTime*2){
			restore(2);
			lock(0);
			lock(1);
			moveRight(2);
		}else if(walkCount<k*3+waitTime*3){
			stopAllMovement();
		}
		walkCount++;
		if(walkCount>=k*3+waitTime*3){
			walkCount=0;
		}
	}

	void idle(){																//when the spider is hanging from a thread,
		xoff=xoff+0.1;															//its legs move in an idle state using pseudo-random
		for(int i=0;i<6;i++){													//perlin noise numbers.
			noiseSeed(i+12);
			joints[i].setMotorSpeed(motorSpeed/8);
			joints2[i].setMotorSpeed(motorSpeed/8);
			if(noise(xoff)>0.5){
				joints[i].setMotorSpeed(-motorSpeed/8);
				joints2[i].setMotorSpeed(-motorSpeed/8);
			}
		}
		for(int i=0;i<6;i++){
			noiseSeed(i);
			if(noise(xoff)>=0.5){
				joints[i].enableMotor(true);
			}else{
				joints[i].enableMotor(false);
			}
		}
		for(int i=0;i<6;i++){
			noiseSeed(i+6);
			if(noise(xoff)>=0.5){
				joints2[i].enableMotor(true);
			}else{
				joints2[i].enableMotor(false);
			}
		}
	}

	void scroll(){																//the screen scrolls when the spider gets close to the borders.
		if(idle==false && currentPos().x>width*3/4+worldX){
			worldX+=1;
		}else if(idle==false && currentPos().x<width*1/4+worldX){
			worldX-=1;
		}
		if(idle==true && currentPos().y>height*1/2+worldY){
			worldY+=1;
		}else if(currentPos().y<height*1/4+worldY){
			worldY-=1;
		}else if(idle==false&&currentPos().y>height*3/4+worldY){
			worldY+=5;
		}
	}

	void applyForce(Vec2 force){												//force is applied in case of wind
		Vec2 pos=body.getWorldCenter();
		body.applyForce(force,pos);
	}

}