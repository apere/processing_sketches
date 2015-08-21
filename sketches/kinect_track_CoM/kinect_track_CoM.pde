/* Adam Pere
 * This program finds the people in the room, gives them a unique user ID, and tracks the center of their mass
 * Some code sampled from SimpleOpenNI User3D Test (Max Rheiner)
 */
 
 
import SimpleOpenNI.*;

SimpleOpenNI kinect;
float        zoomF =0.5f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
                                   // the data from openni comes upside down
float        rotY = radians(0);
boolean      autoCalib=true;

PVector      com = new PVector();                                                                   
color[]      userClr = new color[]{ color(255,0,0),
                                    color(0,255,0),
                                    color(0,0,255),
                                    color(255,255,0),
                                    color(255,0,255),
                                    color(0,255,255)
                                  };
                                   
void setup()
{
  size(1024,768,P3D);  // strange, get drawing error in the cameraFrustum if i use P3D, in opengl there is no problem
  kinect = new SimpleOpenNI(this);
  if(kinect.isInit() == false)
  {
     println("Can't initialize SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }

  // disable mirror
  kinect.setMirror(false);

  // enable depthMap generation 
  kinect.enableDepth();

  // enable skeleton generation for all joints
  kinect.enableUser();

  stroke(255,255,255);
  smooth();  
  perspective(radians(45),
              float(width)/float(height),
              10,150000);
 }

void draw()
{
  // update the cam
  kinect.update();

  background(0,0,0);
  
  // set the scene pos
  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);
  
  int[]   depthMap = kinect.depthMap();
  int[]   userMap = kinect.userMap();
  int     steps   = 3;  // to speed up the drawing, draw every third point
  int     index;
  PVector realWorldPoint; 
 
  translate(0,0,-1000);  // set the rotation center of the scene 1000 infront of the camera

  // draw the pointcloud
  beginShape(POINTS);
  for(int y=0;y < kinect.depthHeight();y+=steps)
  {
    for(int x=0;x < kinect.depthWidth();x+=steps)
    {
      index = x + y * kinect.depthWidth();
      if(depthMap[index] > 0)
      { 
        // draw the projected point
        realWorldPoint = kinect.depthMapRealWorld()[index];
        if(userMap[index] == 0)
          stroke(100); 
        else
          stroke(userClr[ (userMap[index] - 1) % userClr.length ]);        
        
        point(realWorldPoint.x,realWorldPoint.y,realWorldPoint.z);
      }
    } 
  } 
  endShape();
  
  // draw the skeleton if it's available
  // draw center of mass
  int[] userList = kinect.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    
    // draw the center of mass
    if(kinect.getCoM(userList[i],com))
    {
      stroke(100,255,0);
      strokeWeight(1);
      beginShape(LINES);
        vertex(com.x - 15,com.y,com.z);
        vertex(com.x + 15,com.y,com.z);
        
        vertex(com.x,com.y - 15,com.z);
        vertex(com.x,com.y + 15,com.z);

        vertex(com.x,com.y,com.z - 15);
        vertex(com.x,com.y,com.z + 15);
      endShape();
      
      fill(0,255,100);
      text(Integer.toString(userList[i]),com.x,com.y,com.z);
    }      
  }    
 
  // draw the kinect cam
  kinect.drawCamFrustum();
} 
        
// -----------------------------------------------------------------
// SimpleOpenNI user events

void onNewUser(SimpleOpenNI curkinect,int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  kinect.startTrackingSkeleton(userId); //Do I want this line???????
}

void onLostUser(SimpleOpenNI curkinect,int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curkinect,int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


// -----------------------------------------------------------------
// Keyboard events

void keyPressed()
{
  switch(key)
  {
  case ' ':
    kinect.setMirror(!kinect.mirror());
    break;
  }
    
  switch(keyCode)
  {
    case LEFT:
      rotY += 0.1f;
      break;
    case RIGHT:
      // zoom out
      rotY -= 0.1f;
      break;
    case UP:
      if(keyEvent.isShiftDown())
        zoomF += 0.01f;
      else
        rotX += 0.1f;
      break;
    case DOWN:
      if(keyEvent.isShiftDown())
      {
        zoomF -= 0.01f;
        if(zoomF < 0.01)
          zoomF = 0.01;
      }
      else
        rotX -= 0.1f;
      break;
  }
}                                  
