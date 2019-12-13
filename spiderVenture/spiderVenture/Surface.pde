class Surface{
	ArrayList<Vec2> surface;
	float rotAngle;
	Vec2[] vertices;
	ChainShape chain;
	RevoluteJoint joint;
	Body body;
	Body center;

	Surface(){																//this is the ground for the final section of the game.
		surface= new ArrayList<Vec2>();
		int x=-width;
		int y=0;
		float t=0;
		ChainShape centChain;

		surface.add(new Vec2(-width*2,height*2+height*48/8));

		surface.add(new Vec2(-width*2,height*1/4+height*48/8));

		for(int i=-width*2;i<width*3;i+=5){										//the surface is a bit textured using the noise function.
			t+=0.05;															//it's a bit more texture the farther from the middle.
			int k;
			if(i<width/2){
				k=int(map(i,-width*2,width/2,32,128));
			}else{
				k=int(map(i,width/2,width*3,128,32));
			}
			y=int(noise(t)*height/k)+height*1/4+height*48/8;
			surface.add(new Vec2(i,y));
		}

		surface.add(new Vec2(width*3,height*1/4+height*48/8));


		surface.add(new Vec2(width*3,height*2+height*48/8));
		chain=new ChainShape();
		vertices=new Vec2[surface.size()];

		for(int i=0;i<vertices.length;i++){
			vertices[i]=box2d.coordPixelsToWorld(surface.get(i));
		}

		chain.createChain(vertices,vertices.length);
		BodyDef bd=new BodyDef();
		bd.type=BodyType.KINEMATIC;
		bd.fixedRotation=false;
		body=box2d.world.createBody(bd);
		FixtureDef fd=new FixtureDef();
		fd.shape=chain;
		fd.density=1;
		fd.friction=1.0;
		fd.restitution=0;
		body.createFixture(fd);
		
		body.setUserData(this);
	}

	void display(){

		rotAngle+=0.01;
		fill(255);
		stroke(255,255,255);
		strokeWeight(1);
		pushMatrix();
		beginShape();
		for(Vec2 v: surface){
			vertex(v.x-worldX,v.y-worldY);
		}
		vertex(width,height);
		vertex(0,height);
		endShape(CLOSE);
		popMatrix();
	}

}

