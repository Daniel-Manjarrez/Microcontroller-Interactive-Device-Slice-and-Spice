import processing.serial.*;
import java.util.ArrayList;

Serial myPort;  // Create object from Serial class
String val;      // Data received from the serial port

int canvasSize = 500;
int analogMax = 4095;
int score = 0;
int lives = 100;
boolean superOn = false;
boolean screenFlash = false;  // To handle the flash effect
int flashDuration = 10;  // Duration of the flash in frames
int flashTimer = 0;
int difficulty = 0;

ArrayList<PolygonShape> polygons = new ArrayList<PolygonShape>();
ArrayList<PVector> sliceTrail = new ArrayList<PVector>();  // To store the joystick positions for the slice trail
ArrayList<Particle> particles = new ArrayList<Particle>();  // Store particles for burst effect
int trailLength = 10;  // Max length of the slice trail
boolean isJoystickActive = false;  // Tracks whether joystick is actively moving

boolean gameOver = false;int buttonX, buttonY, buttonWidth, buttonHeight;

void setup()
{
  size(500, 500);
  printArray(Serial.list());
  String portName = Serial.list()[0];
  println(portName);
  myPort = new Serial(this, portName, 9600); // ensure baudrate is consistent with arduino sketch
  
  // Start with 3 polygons
  for (int i = 0; i < 3; i++) {
    polygons.add(new PolygonShape());
  }
  
  buttonX = width / 2 - 75;
  buttonY = height / 2 + 50;
  buttonWidth = 150;
  buttonHeight = 50;
  
  resetGame();
}

void draw()
{
  background(0);
  
  if (gameOver) {
    displayGameOverScreen();
  }
  else {
    if (screenFlash) {
      background(255, 0, 0);  // Flash the screen red
      flashTimer++;
      if (flashTimer > flashDuration) {
        screenFlash = false;  // End the flash after the duration
        flashTimer = 0;
      }
    } else {
      background(255);  // Regular white background
    }
    
    // Display score and lives
    displayScoreAndLives();
    
    // Read joystick input
    if ( myPort.available() > 0) {
      val = myPort.readStringUntil('\n');  // Read joystick data
    }
    
    val = trim(val);
    
    if (val != null) {
      //println(val);
      int[] xyz = int(split(val, ','));
  
      if (xyz.length == 5) {
        int x = xyz[0];
        int y = xyz[1];
        int z = xyz[2];
        int button = xyz[3];
        int pentVal = xyz[4];
  
        // Map joystick input to slicing position
        float sliceX = map(x, 0, analogMax, 0, canvasSize);
        float sliceY = map(y, 0, analogMax, 0, canvasSize);
        
        // If joystick moves from the center, consider it active
        isJoystickActive = (x != analogMax/2 || y != analogMax/2);
        
        // Add the current position to the slice trail
        sliceTrail.add(new PVector(sliceX, sliceY));
        if (sliceTrail.size() > trailLength) {
          sliceTrail.remove(0);  // Remove the oldest point if the trail is too long
        }
        
        // Draw the swipe trail based on joystick movement
        drawSwipeTrail(z);
  
        // Check if the button (z == 0) is pressed to slice all polygons
        if (z == 0) {
          if (superOn) {
            sliceAllPolygons();  // Slice everything on screen
            triggerScreenFlash();  // Activate screen flash effect
            superOn = false;
          }
        }
        
        if (pentVal < 10) {
          difficulty = 0;
        }
        else if (pentVal >= 10 && pentVal <= 100) {
          difficulty = 1;
        }
        else if (pentVal > 100) {
          difficulty = 2;
        }
        
        // Check if the button is pressed to spice all sliced polygons
        if (button == 0) {
          spiceSlicedPolygons();
        }
        
        // Super Meter Logic Based on Difficulty
        if (score != 0) {
          if (difficulty == 0 && score % 30 == 0) {
            superOn = true;
          }
          else if (difficulty == 1 && score % 50 == 0) {
            superOn = true;
          }
          else if (difficulty == 2 && score % 70 == 0) {
            superOn = true;
          }
        }
        
        if(superOn == false) {
          myPort.write("LED_OFF\n");
        }
        
        if (superOn) {
          myPort.write("LED_ON\n");
        }
  
        // Update and display polygons
        for (int i = polygons.size() - 1; i >= 0; i--) {
          PolygonShape poly = polygons.get(i);
          poly.update();
          poly.display();
          
          // Check for slicing collision along the entire trail
          if (checkTrailCollision(poly) && (!poly.sliced && !poly.spiced)) {
            score++;
            poly.setSliced(true);  // Mark the polygon as sliced
            addBurstParticles(poly.x, poly.y);  // Emit particles for slicing effect
            if (difficulty == 0) {
              println("Sliced! Score: " + score + " on Easy with pentVal " + pentVal);
            }
            else if (difficulty == 1) {
              println("Sliced! Score: " + score + " on Medium with pentVal " + pentVal);
            }
            else if (difficulty == 2) {
              println("Sliced! Score: " + score + " on Hard with pentVal " + pentVal);
            }
            break;  // Stop checking once sliced
          }
  
          // Check if polygon hits the bottom
          if (poly.y > height && !poly.spiced) {
            lives--;
            polygons.remove(i);  // Remove polygon that reached the bottom
            println("Missed! Lives left: " + lives);
            if (lives <= 0) {
              println("Game Over! Final Score: " + score);
              gameOver = true;
            }
          }
          else if (poly.y > height) {
            polygons.remove(i);  // Remove polygon that reached the bottom
          }
        }
        
        // Add new polygons to the game
        if (polygons.size() < 3) {
          polygons.add(new PolygonShape());
        }
      }
    }
  
    // Update and draw burst particles
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();
      p.display();
      if (p.isFinished()) {
        particles.remove(i);  // Remove particle once it's done
      }
    }
  }
}

void spiceSlicedPolygons() {
  for (int i = polygons.size() - 1; i >= 0; i--) {
    PolygonShape poly = polygons.get(i);
    if (poly.sliced && !poly.spiced) {
      addBurstParticles(poly.x, poly.y);  // Emit particles
      poly.setSpiced(true);
      score++;
    }
  }
}

// Draw the swipe trail
void drawSwipeTrail(int z) {
  stroke(255, 0, 0);
  strokeWeight(map(z, 0, analogMax, 8, 8));  // Thickness depends on Z-axis
  noFill();
  beginShape();
  for (PVector p : sliceTrail) {
    vertex(p.x, p.y);
  }
  endShape();
}

void displayGameOverScreen() {
  fill(255, 0, 0);  // Red text
  textAlign(CENTER);
  textSize(48);
  text("GAME OVER", width / 2, height / 2 - 50);

  // Button
  fill(0, 255, 0);  // Green button
  rect(buttonX, buttonY, buttonWidth, buttonHeight);
  
  fill(0);  // Black text inside the button
  textSize(24);
  text("Restart", width / 2, buttonY + 32);
  
  displayScoreAndLives();
  buttonPressedForRestart();
}

void buttonPressedForRestart() {
  if (gameOver) {
    // Check if mouse is within button bounds
    if ( myPort.available() > 0) {
      val = myPort.readStringUntil('\n');  // Read joystick data
    }
    val = trim(val);
    if (val != null) {
      int[] xyz = int(split(val, ','));
      int buttonPress = xyz[3];
      if (buttonPress == 0) {
        resetGame();
      }
    }   
  }
}

void resetGame() {
  score = 0;
  lives = 20;
  gameOver = false;
  polygons.clear();
}

void displayScoreAndLives() {
  // Shadow effect for the text
  fill(0, 0, 0, 50);  // Black shadow with some transparency
  textSize(36);
  textAlign(CENTER);
  text("Score: " + score, width / 2 + 3, 53);  // Slight offset for shadow
  text("Lives: " + lives, width / 2 + 3, 103);

  // Main text
  fill(255, 255, 0);  // Bright yellow
  stroke(0);  // Black outline
  strokeWeight(3);  // Outline thickness
  textSize(36);
  text("Score: " + score, width / 2, 50);  // Centered at top
  text("Lives: " + lives, width / 2, 100);
}


// Check for collision with the entire trail
// Check if a polygon is sliced by the swipe trail, now considering the line segment between the head and tail
boolean checkTrailCollision(PolygonShape poly) {
  if (sliceTrail.size() < 2) {
    return false;  // Need at least two points in the trail to create a line segment
  }
  
  // Get the head (most recent position) and tail (oldest position) of the trail
  PVector head = sliceTrail.get(sliceTrail.size() - 1);
  PVector tail = sliceTrail.get(0);
  
  // Check if the polygon's center is within the trail
  if (poly.isSliced(head.x, head.y) || poly.isSliced(tail.x, tail.y)) {
    return true;  // Immediate check for head or tail collision
  }
  
  // Calculate the distance from the polygon's center to the line segment formed by head and tail
  float distToLine = pointToLineDistance(poly.x, poly.y, tail.x, tail.y, head.x, head.y);
  
  // If the distance is smaller than the polygon's radius (size), consider it sliced
  if (distToLine < poly.size / 2) {
    return true;
  }
  
  return false;
}

// Helper function to calculate the shortest distance from a point (px, py) to a line segment (x1, y1) -> (x2, y2)
float pointToLineDistance(float px, float py, float x1, float y1, float x2, float y2) {
  // Line segment vector
  PVector lineVec = new PVector(x2 - x1, y2 - y1);
  PVector pointVec = new PVector(px - x1, py - y1);
  
  float lineLenSq = lineVec.magSq();  // Squared length of the line segment
  
  if (lineLenSq == 0) {
    return PVector.dist(new PVector(px, py), new PVector(x1, y1));  // Line is a single point
  }
  
  // Projection of the point onto the line segment (clamped between 0 and 1)
  float t = constrain(PVector.dot(pointVec, lineVec) / lineLenSq, 0, 1);
  
  // Find the projection point on the line
  PVector projPoint = new PVector(x1, y1).add(lineVec.mult(t));
  
  // Return the distance from the point to the projection point on the line
  return PVector.dist(new PVector(px, py), projPoint);
}

// Slice all polygons on the screen and trigger the burst effect
void sliceAllPolygons() {
  for (int i = polygons.size() - 1; i >= 0; i--) {
    PolygonShape poly = polygons.get(i);
    addBurstParticles(poly.x, poly.y);  // Emit particles
    poly.setSliced(true);  // Mark the polygon as sliced
    score++;
  }
  println("Sliced everything! Score: " + score);
}

// Add particles for a burst effect from a polygon's position
void addBurstParticles(float x, float y) {
  int numParticles = 20;  // Number of particles per burst
  for (int i = 0; i < numParticles; i++) {
    particles.add(new Particle(x, y, random(TWO_PI)));
  }
}

// Trigger screen flash
void triggerScreenFlash() {
  screenFlash = true;
}

// Class to represent the falling polygons
class PolygonShape {
  float x, y;
  int sides;
  float size;
  float speed;
  color col;
  boolean sliced;  // Track if the polygon has been sliced
  boolean spiced;
  
  PolygonShape() {
    x = random(width);
    y = 0;
    sides = int(random(3, 6));
    size = random(20, 50);
    speed = random(2, 5);
    col = color(random(255), random(255), random(255));
    sliced = false;  // Initially not sliced
    spiced = false;
  }
  
  void update() {
    y += speed;  // Move the polygon down
  }
  
  void display() {
    if (spiced) {
      stroke(0);  // Border for sliced shape
      strokeWeight(2);
      fill(255, 165, 0, 150); // Git it an orange fill
    }
    else if (sliced) {
      stroke(0);  // Border for sliced shape
      strokeWeight(2);
      fill(255, 0, 0, 150);  // Give it a red fill
    } else {
      fill(col);
      noStroke();
    }
    
    beginShape();
    for (int i = 0; i < sides; i++) {
      float angle = TWO_PI / sides * i;
      float xPos = x + cos(angle) * size;
      float yPos = y + sin(angle) * size;
      vertex(xPos, yPos);
    }
    endShape(CLOSE);
  }
  
  boolean isSliced(float px, float py) {
    // Check if the given point (px, py) is inside the polygon
    return (dist(px, py, x, y) < size / 2);  // Simple distance check
  }
  
  void setSliced(boolean value) {
    sliced = value;
  }
  
  void setSpiced(boolean value) {
    spiced = value;
  }
}

// Class to represent particles for the burst effect
class Particle {
  PVector pos;
  PVector vel;
  float lifespan;  // Lifespan of the particle
  
  Particle(float x, float y, float angle) {
    pos = new PVector(x, y);
    vel = PVector.fromAngle(angle).mult(random(1, 3));  // Random speed and direction
    lifespan = 255;  // Start with full opacity
  }
  
  void update() {
    pos.add(vel);  // Move the particle
    lifespan -= 5;  // Decrease lifespan over time
  }
  
  void display() {
    stroke(0, lifespan);  // Fade out as lifespan decreases
    strokeWeight(2);
    point(pos.x, pos.y);
  }
  
  boolean isFinished() {
    return (lifespan < 0);  // Check if particle has faded out
  }
}