class Fallen extends Spider{

	int count;

	Fallen(float x_,float y_,float d){
		super(x_,y_,d);
		count=0;
	}
	void lock(int i){								//locking more joints than for a normal spider causes the spider to glitch out,
		joints2[2-i].setLimits(0,0);				//creating the fallen.
		joints2[i+3].setLimits(0,0);
		joints[2-i].setLimits(joints[2-i].getJointAngle(),joints[2-i].getJointAngle());
		joints[i+3].setLimits(joints[i+3].getJointAngle(),joints[i+3].getJointAngle());
	}

	void restore(int i){
		joints2[2-i].setLimits(-PI/4,PI/4);
		joints2[i+3].setLimits(-PI/4,PI/4);
		joints[i+3].setMotorSpeed(motorSpeed);
		joints2[i+3].setMotorSpeed(motorSpeed);
		joints[2-i].setMotorSpeed(motorSpeed);
		joints[2-i].setMotorSpeed(motorSpeed);
		joints[2-i].setLimits(-PI/4,PI/4);
		joints[i+3].setLimits(-PI/4,PI/4);
	}

	void update(){
		if (count<30){								//going forward for a few frames triggers the fallen to go crazy.
			goForward();
		}
		count++;
		if(currentPos().y<worldY-height/2 || (worldY>height*35/8 && currentPos().y>worldY+height+20)){
			killBody();
			dead=true;
		}
	}
}