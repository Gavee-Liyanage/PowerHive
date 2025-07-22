#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <addons/TokenHelper.h>

// Wi-Fi & Firebase
#define WIFI_SSID "M31EBB7"
#define WIFI_PASSWORD "12131415"

#define API_KEY "AIzaSyBM3j7Z5dWy2qpURXPmAQPwnGooa52Rdfw"
#define DATABASE_URL "https://power-hive-94c09-default-rtdb.asia-southeast1.firebasedatabase.app/"

#define USER_EMAIL "dewmi@gmail.com"
#define USER_PASSWORD "123456"

// Firebase objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// LCD
LiquidCrystal_I2C lcd(0x27, 16, 2);

// User Info
String userId = "PSZyTf2pqEZgzCb6gchZJ3bTRUJ3";
String sessionPath = "";

// Relay Pins
#define RELAY_MOBILE1 18
#define RELAY_MOBILE2 19
#define RELAY_CAR 23

// Port availability paths
String port1Path = "/ports/port1";  // Mobile Port 1
String port2Path = "/ports/port2";  // Mobile Port 2
String portEVPath = "/ports/ev1";   // EV Port (NEW)

// Charging Session Variables
unsigned long chargingStart = 0;
unsigned long chargingDuration = 0;
bool chargingActive = false;
String chargingType = "";
bool paymentConfirmed = false;

unsigned long lastCheckTime = 0; // for millis()

// Function Prototypes
unsigned long parseDurationToSeconds(String durationStr);
void stopCharging();
void updatePortAvailability();

void setup() {
  Serial.begin(115200);
  Wire.begin(21, 22);

  lcd.init();
  lcd.backlight();

  pinMode(RELAY_MOBILE1, OUTPUT);
  pinMode(RELAY_MOBILE2, OUTPUT);
  pinMode(RELAY_CAR, OUTPUT);

  // Initially OFF
  digitalWrite(RELAY_MOBILE1, LOW);
  digitalWrite(RELAY_MOBILE2, LOW);
  digitalWrite(RELAY_CAR, LOW);

  lcd.setCursor(0, 0);
  lcd.print("Connecting WiFi");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  lcd.clear();
  lcd.print("WiFi Connected");

  // Firebase config
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  config.token_status_callback = tokenStatusCallback;

  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  while (!Firebase.ready()) {
    delay(500);
    Serial.print(".");
  }

  lcd.setCursor(0, 1);
  lcd.print("Firebase Ready");

  // Set session path
  sessionPath = "chargingSessions/" + userId + "/activeSession";

  // Set initial port statuses
  Firebase.RTDB.setString(&fbdo, port1Path, "available");
  Firebase.RTDB.setString(&fbdo, port2Path, "available");
  Firebase.RTDB.setString(&fbdo, portEVPath, "available");
}

void loop() {
  if (!Firebase.ready()) return;

  unsigned long currentMillis = millis();
  if (currentMillis - lastCheckTime >= 2000) {
    lastCheckTime = currentMillis;

    // Real-time update of port availability
    updatePortAvailability();

    if (!chargingActive && sessionPath != "") {
      if (Firebase.RTDB.getJSON(&fbdo, sessionPath.c_str())) {
        FirebaseJson& json = fbdo.jsonObject();
        FirebaseJsonData result;

        json.get(result, "chargingType");
        chargingType = result.stringValue;

        json.get(result, "duration");
        chargingDuration = parseDurationToSeconds(result.stringValue);

        json.get(result, "paymentConfirmed");
        paymentConfirmed = result.boolValue;

        json.get(result, "status");
        bool startCommand = (result.stringValue == "start");

        if (!paymentConfirmed) {
          lcd.setCursor(0, 0);
          lcd.print("Payment Pending ");
          return;
        }

        if (paymentConfirmed && chargingDuration > 0 && startCommand) {
          chargingStart = millis();
          chargingActive = true;
          lcd.clear();
          lcd.print("Charging Started");

          if (chargingType == "Mobile1") digitalWrite(RELAY_MOBILE1, HIGH);
          else if (chargingType == "Mobile2") digitalWrite(RELAY_MOBILE2, HIGH);
          else if (chargingType == "Car" || chargingType == "EV") digitalWrite(RELAY_CAR, HIGH);

          FirebaseJson updatePayload;
          updatePayload.set("status", "charging");
          Firebase.RTDB.updateNode(&fbdo, sessionPath.c_str(), &updatePayload);
        }
      }
    }

    if (chargingActive) {
      unsigned long elapsed = (millis() - chargingStart) / 1000;
      unsigned long remaining = (chargingDuration > elapsed) ? (chargingDuration - elapsed) : 0;

      lcd.setCursor(0, 1);
      lcd.print("Time: " + String(remaining) + "s ");

      if (remaining <= 0) stopCharging();
    }
  }
}

unsigned long parseDurationToSeconds(String durationStr) {
  int h = durationStr.substring(0, durationStr.indexOf(':')).toInt();
  int m = durationStr.substring(durationStr.indexOf(':') + 1, durationStr.lastIndexOf(':')).toInt();
  int s = durationStr.substring(durationStr.lastIndexOf(':') + 1, durationStr.indexOf('.')).toInt();
  return h * 3600 + m * 60 + s;
}

void stopCharging() {
  digitalWrite(RELAY_MOBILE1, LOW);
  digitalWrite(RELAY_MOBILE2, LOW);
  digitalWrite(RELAY_CAR, LOW);
  chargingActive = false;

  FirebaseJson updatePayload;
  updatePayload.set("status", "available");
  Firebase.RTDB.updateNode(&fbdo, sessionPath.c_str(), &updatePayload);

  lcd.clear();
  lcd.print("Charging Done");
  lcd.setCursor(0, 1);
  lcd.print("Port Available");

  // Immediately update port availability after stopping
  updatePortAvailability();
}

void updatePortAvailability() {
  // Relay state = HIGH → IN USE → unavailable
  String port1Status = (digitalRead(RELAY_MOBILE1) == HIGH) ? "unavailable" : "available";
  String port2Status = (digitalRead(RELAY_MOBILE2) == HIGH) ? "unavailable" : "available";
  String evPortStatus = (digitalRead(RELAY_CAR) == HIGH) ? "unavailable" : "available";

  Firebase.RTDB.setString(&fbdo, port1Path, port1Status);
  Firebase.RTDB.setString(&fbdo, port2Path, port2Status);
  Firebase.RTDB.setString(&fbdo, portEVPath, evPortStatus);
}
