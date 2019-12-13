import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import java.util.Collections;

import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;

Surface mySurface;
Spider spider;
ArrayList<Spider> spiders;
ArrayList<Boundary> boundaries;
ArrayList<Fallen> fallen;


Box2DProcessing box2d;

int lifetime;
int numSpiders;

int worldX;
int worldY;

int fallenAdded;

Thread thread;

PFont font;

boolean input;

int textOpacity;
int textCount;
boolean textFade;

boolean goingDown;

int lastPress;

int[] volumes;

void setup(){
	font=createFont("8bitoperator",32);
	textFont(font);
	textAlign(CENTER);

	goingDown=false;
	lastPress=0;

	volumes=new int[4];													//volumes of the 4 different tracks that may play
	volumes[0]=100;
	volumes[1]=0;
	volumes[2]=0;
	volumes[3]=100;

	input=false;
	textFade=false;
	textOpacity=0;
	textCount=0;

	frameCount=0;	//this is reset because input may be called several times during the same program
	worldX=0;		//x coordinate of the screen scroll
	worldY=0;		//y coordinate of the screen scroll

	fallenAdded=0;

	oscP5 = new OscP5(this,12000);										//		oscP5 communicates information between Processing to switch between 
	myRemoteLocation = new NetAddress("127.0.0.1",12000);				//	music tracks dynamically

	OscMessage myMessage = new OscMessage("/test");						//this message starts the intro music
  	myMessage.add(1); 
  	for(int i=0;i<volumes.length;i++){
  		myMessage.add(volumes[i]);
  	}
 	oscP5.send(myMessage, myRemoteLocation); 

	fullScreen();
	background(255);
	box2d=new Box2DProcessing(this);
	box2d.createWorld();
	box2d.setGravity(0,-10);


	spider=new Spider(width/2,height/4,1.0);
	spiders=new ArrayList<Spider>();
	spiders.add(spider);

	fallen=new ArrayList<Fallen>();

	thread=new Thread(spider);

	boundaries=new ArrayList<Boundary>();

  	int relWidth=width/3;

  	boundaries.add(new Boundary(0,height/2,relWidth*2,height*9.8,0));			//		the first two boundaries are the barriers that make
  	boundaries.add(new Boundary(width,height/2,relWidth*2,height*9.8,0));		//	the screen narrow in the first part of the game

  	boundaries.add(new Boundary(relWidth+relWidth/4,height+50,relWidth*1/4,10,0));

  	boundaries.add(new Boundary(relWidth+relWidth*5/8,height*10/8,relWidth/4,10,0));
  	boundaries.add(new Boundary(relWidth+20,height*12/8,relWidth*2/3,10,0));
  	boundaries.add(new Boundary(relWidth+relWidth*3/8,height*15/8,relWidth*4/8,10,0));
  	boundaries.add(new Boundary(relWidth+relWidth*6/8,height*16/8,relWidth,10,0));
  	boundaries.add(new Boundary(relWidth+relWidth*4/8,height*18/8,relWidth*3/8,10,0));

  	

  	boundaries.add(new Boundary(0,height*20/8,relWidth*5/4,10,0));
  	boundaries.add(new Boundary(relWidth+relWidth/4,height*22/8,relWidth/3,10,0));
  	boundaries.add(new Boundary(relWidth+relWidth/2,height*24/8,relWidth/4,10,0));

  	

  	boundaries.add(new Boundary(relWidth+relWidth*7/8,height*27/8,relWidth/4,10,0));
	boundaries.add(new Boundary(relWidth+relWidth/8,height*27/8,relWidth*7/8,10,0));
	boundaries.add(new Boundary(relWidth+relWidth*5/8,height*29/8,relWidth*3/8,10,0));



	boundaries.add(new Boundary(relWidth+relWidth/8,height*32/8,relWidth/4,10,0));
	boundaries.add(new Boundary(relWidth+relWidth*7/8,height*32/8,relWidth*7/8,10,0));
	boundaries.add(new Boundary(relWidth+relWidth*6/8,height*35/8,relWidth*2/8,10,0));
	boundaries.add(new Boundary(relWidth+relWidth*1/8,height*37/8,relWidth*1/8,10,0));
	boundaries.add(new Boundary(relWidth+relWidth*3/8,height*40/8,relWidth*1/8,10,0));

	mySurface=new Surface();											//the ground at the end of the game

  	fullScreen();

}

void draw(){

	if(lastPress>0){				
		lastPress--;
	}

	if(lastPress==250){					//		if it's been a long enough since the last time a button was pressed, the volumes
		if(volumes[0]>0){				//	of the track changes accordingly. it changes back when a button is pressed
			volumes[0]--;
			volumes[3]--;
		}
		if(volumes[1]<100){
			volumes[1]++;
			volumes[2]++;
		}
	}else if(lastPress==0){
		if(volumes[0]<100){
			volumes[0]++;
			volumes[3]++;
		}
		if(volumes[1]>0){
			volumes[1]--;
			volumes[2]--;
		}
	}

	if(thread.hacked==false){											//the music changes once the thread is cut or "hacked"
		OscMessage myMessage = new OscMessage("/test");		
  		myMessage.add(3); 
  		for(int i=0;i<volumes.length;i++){
  			myMessage.add(volumes[i]);
  		}
 		oscP5.send(myMessage, myRemoteLocation); 
	}else if(thread.hacked==true){
		OscMessage myMessage = new OscMessage("/test");
  		myMessage.add(3); 
  		for(int i=0;i<volumes.length;i++){
  			myMessage.add(volumes[i]);
  		}
 		oscP5.send(myMessage, myRemoteLocation); 
	}

	background(0);
	box2d.step();

	mySurface.display();

	for (Spider spider:spiders){			//the spider legs move automatically when it's hanging off the thread
		if(spider.idle==true){
			spider.idle();
		}
		spider.scroll();					//scrolling the screen
	}

	fill(255);

	for (Boundary wall: boundaries) {
    	wall.display();
  	}

	for (Spider spider : spiders){			//wind happens if left or right is pressed during the first section
		spider.applyForce(spider.wind);
		spider.display();
	}
	for(int i=0;i<fallen.size();i++){
		fallen.get(i).display();
		fallen.get(i).update();
		if(fallen.get(i).dead==true){
			fallen.remove(i);
			i--;
		}
	}

	thread.dj.setLength(thread.dj.getLength()+thread.mod);	//the thread length changes every frame
	thread.display();

	int relWidth=width/3;

	if(worldY>=height*10.5/8 && fallenAdded==0){							//fallen spiders only appear once the player gets near them
		fallen.add(new Fallen(relWidth+relWidth*1/4,height*19/8,0.01));
		fallenAdded++;
	}else if(worldY>=height*17.5/8 && fallenAdded==1){
		fallen.add(new Fallen(relWidth+relWidth*1/4,height*26/8,0.01));
		fallenAdded++;
	}else if(worldY>=height*22.5/8 && fallenAdded==2){
		fallen.add(new Fallen(relWidth+relWidth/4,height*31/8,0.01));
		fallen.add(new Fallen(relWidth+relWidth*3/4,height*31/8,0.01));
		fallenAdded+=2;
	}

	if(textFade==false){													//animation for the text fading in and out
		textOpacity+=1;
	}else{
		textOpacity-=1;
	}
	if(textOpacity==160||textOpacity==0){
		textFade=!textFade;
		if(thread.hacked==true && textOpacity==0){
			textCount++;
		}
	}

	println(textCount);

	if(textCount>4){													//at the end, the text disappears
		textOpacity=0;
	}

	fill(255,textOpacity);
	rectMode(CENTER);

	

	text("Press Down to Descend",width/2,height*5/8-worldY);
	text("This is your Spider.",width/2,height*11/8-worldY);
	text("You must take care of it.",width/2,height*13.5/8-worldY);
	text("During your travels, you may encounter a Fallen Spider.",width/2,height*17/8-worldY,relWidth*7/8,height*1/8);
	text("They mean no harm. Just ignore them.",width/2,height*19/8-worldY,relWidth*7/8,height*1/8);
	text("Still there?",width/2,height*36/8-worldY);
	text("It's time to let go now. Once you are stable, press C.",width/2-worldX,height*46/8-worldY,relWidth*7/8,height*2/8);
	fill(0,textOpacity);
	text("You are free now. Press A, S, or D to move individual legs.",width/2-worldX,height*53/8-worldY-20,relWidth*7/8,height/8);

}

void keyPressed(){
	lastPress=251;
	if(key==' '){
		setup();
	}
	if(key=='a'){
		for (Spider spider : spiders){			//when the player moves a pair of legs, the others are locked in place for more stability
			spider.restore(0);
			spider.lock(1);
			spider.lock(2);
			spider.moveRight(0);
		}
	}
	if(key=='s'){
		for (Spider spider : spiders){
			spider.restore(1);
			spider.lock(0);
			spider.lock(2);
			spider.moveRight(1);
		}

	}
	if(key=='d'){
		for (Spider spider : spiders){
			spider.restore(2);
			spider.lock(0);
			spider.lock(1);
			spider.moveRight(2);
		}

	}

	if(keyCode==39 && spider.idle==false){			
		for(Spider spider:spiders){				//an attempt at automating the walk cycle
			spider.goForward();
		}
	}else if(keyCode==39){
		for(Spider spider:spiders){				//wind is blown when the spider is hanging
			spider.wind=new Vec2(100,0);
		}
	}
	if(keyCode==37 && spider.idle==true){
		for(Spider spider:spiders){
			spider.wind=new Vec2(-100,0);
		}		
	}
	if(keyCode==40){							//the thread gets longer or shorter
		if(thread.mod<0.2){
			thread.mod+=0.1;
		}
		input=true;
	}else if(keyCode==38){
		thread.mod=-0.1;
	}

}

void keyReleased(){
	if(key=='a'){
		for (Spider spider : spiders){				//movement is stopped when a key is released
			spider.stopMovement(0);
		}
	}
	if(key=='s'){
		for (Spider spider : spiders){
			spider.stopMovement(1);
		}
	}
	if(key=='d'){
		for (Spider spider : spiders){
			spider.stopMovement(2);
		}
	}
	if(keyCode==39 && spider.idle==false){
		for(Spider spider:spiders){
			spider.stopAllMovement();
		}
	}
	if(keyCode==39||keyCode==37){
		for(Spider spider:spiders){
			spider.wind=new Vec2(0,0);
		}		
	}
	if(keyCode==40 || keyCode==38){
		thread.mod=0.0;
	}
	if(key=='c'){									//cutting the thread
		if(thread.hacked==false){
			thread.hack();
			OscMessage myMessage = new OscMessage("/test");
  			myMessage.add(2); 
 			oscP5.send(myMessage, myRemoteLocation); 
 		}
	}
}