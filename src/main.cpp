#include <Arduino.h>

#define LED_PIN 15

void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
}

void loop() {
  digitalWrite(LED_PIN, HIGH);
  Serial.println("State: ON");
  delay(1000);
  digitalWrite(LED_PIN, LOW);
  Serial.println("State: OFF");
  delay(1000);
}

