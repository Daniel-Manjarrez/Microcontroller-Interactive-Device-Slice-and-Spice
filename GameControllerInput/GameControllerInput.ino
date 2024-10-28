#define BUTTON_PIN 2
#define LED_PIN 15
#define POTENTIOMETER_PIN 13

int xyzPins[] = {39, 32, 33};   //x, y, z(switch) pins
void setup() {
  Serial.begin(9600);
  pinMode(xyzPins[2], INPUT_PULLUP);  // pullup resistor for switch
  pinMode(BUTTON_PIN, INPUT_PULLUP); // use internal pullup resistor
  pinMode(LED_PIN, OUTPUT);
}

void loop() {
  int xVal = analogRead(xyzPins[0]);
  int yVal = analogRead(xyzPins[1]);
  int zVal = digitalRead(xyzPins[2]);
  int buttonState = digitalRead(BUTTON_PIN);
  int potVal = analogRead(POTENTIOMETER_PIN);
  Serial.printf("%d,%d,%d,%d,%d", xVal, yVal, zVal, buttonState, potVal);
  Serial.println();
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');  // Read the command from Processing
    if (command == "LED_ON") {
      digitalWrite(LED_PIN, HIGH);  // Turn on the LED
    } else if (command == "LED_OFF") {
      digitalWrite(LED_PIN, LOW);   // Turn off the LED
    }
  }
  delay(100);
}