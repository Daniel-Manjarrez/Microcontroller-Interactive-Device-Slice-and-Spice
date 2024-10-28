# Microcontroller Interactive Device Slice and Spice
A cooking themed interactive device that's a video game controller with a video game designed for an ESP32 microcontroller

*Here's a video of the display in action: https://youtu.be/tnQcMq5Ct8E?feature=shared*

## Blog Post

You can take an in depth look at my process making this program in this blog [post](https://brassy-moonflower-6cd.notion.site/Slice-and-Spice-S2-12d18fb9102d80a786a9e72461ec0fd8?pvs=4)

## Table of Contents

- [Materials](#what-youll-need)
- [Installation Process](#installation)
- [Design Process](#design-process-and-goals)
- [Demos](#demos)
- [Contributors](#contributors)

## What You'll Need

 + [Arduino IDE](https://www.arduino.cc/en/software)
 + USB-C Cable
 + [ESP32 TTGO T-display Microcontroller](https://www.amazon.com/LILYGO-T-Display-Arduino-Development-CH9102F/dp/B099MPFJ9M?th=1)
 + Breadboard
 + 1 LED
 + 1 Potentiometer
 + 1 Joystick
 + 1 Push Button
 + [Jumper Wires] (https://www.digikey.com/en/products/detail/bud-industries/BC-32626/5291560)
 + Male to Female Jumper Wires
 + 3D Printer
 + Adhesive Tape of Your Choosing


## Installation
1. Download the `FallingFoliageFade` folder and open the arduino sketch file inside named `FallingFoliageFade.ino` on Arduino IDE
    * If Arduino IDE is not installed, check the [Arduino Support Page](https://support.arduino.cc/hc/en-us/articles/360019833020-Download-and-install-Arduino-IDE) to learn how to install it

2. Follow [installation steps](https://coms3930.notion.site/Lab-1-TFT-Display-a53b9c10137a4d95b22d301ec6009a94) to correctly set up the libraries needed to write and run this code

3. Once everything is set up, you can connect your ESP32 to your computer via USB-C and click on the `Upload` sketch button on the top left of the Arduino IDE after selecting your board and appropriate configurations. This will make the code compile and store onto the ESP32.
![Connection Shown](images/SetUp.jpg)

4. After confirming that the code compiled and now runs on your ESP32, you can start designing your envelope and inserting your ESP32 microcontroller in the center with the display exposed. You can check this [guide](https://coms3930.notion.site/Module-1-Install-10a350cc6f058045b899e7d3c2a3c8f5) on how to attach the ESP32 and a battery to the envelope.

5. Lastly, feel free to put up your enveloped ESP32 with generative fall art somewhere for display![Enveloped shown](images/TreeShot2.png)

## Design Process and Goals

This image reference is the inspiration behind  the design of my generative fall art that depicts the leaves of a tree falling down and changing color as the days pass throughout the autumn season.

- Fall Leaf Color Reference:

  ![Leaf Colors](images/autumnLeaves.jpg)

This image represents the thought process behind creating the leaves that were displayed in my art.

- Leaf Design Reference:

  ![Leaf Design](images/DesignWork.png)

## Demos

This image showcases the final design of the enveloped generative art display.

- Final Result Static Image: 
![Final Result](images/TreeShot.png)

This image showcases the animated motion of the enveloped generative art display.

- Final Result Animated Image: 

  ![Final Animation](images/Tree.gif)

## Contributors

- Daniel Manjarrez
