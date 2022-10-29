#define pump1 26
#define pump2 4

#include <WiFi.h>
#include <HTTPClient.h>
#include <Arduino_JSON.h>
#define _DISABLE_TLS_

const char ssid[] = "Samsung Galaxy S8+_8653";
const char pw[] = "abcd2001";

HTTPClient http;

int pump1Level = 0;
int pump2Level = 0;
int pump1State = 0;
int pump2State = 0;

unsigned long previous = millis();

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial.println("Hello, ESP32!");

  //WiFi Connection
  Serial.print("Connecting to WiFi");
  WiFi.begin(ssid, pw);
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");  
  }
  Serial.print("OK! IP=");
  Serial.println(WiFi.localIP());

  pinMode(pump1, OUTPUT);
  pinMode(pump2, OUTPUT);
  digitalWrite(pump1, LOW);
  digitalWrite(pump2, LOW);
}

void loop() {
  // put your main code here, to run repeatedly:
//  unsigned long current = millis();
//  if(current - previous >= 10000)
//  {
    readData();
    if (pump1Level < 20)
    {
      digitalWrite(pump1, HIGH);
      pump1State = 1;
      delay(5000);
      digitalWrite(pump1, LOW);
      delay(5000);
    }
    else
    {
      digitalWrite(pump1, LOW);
      pump1State = 0;
    }

    if (pump2Level < 20)
    {
      digitalWrite(pump2, HIGH);
      pump2State = 1;
      delay(5000);
      digitalWrite(pump2, LOW);
      delay(5000);
    }
    else
    {
      digitalWrite(pump2, LOW);
      pump2State = 0;
    }
    postPumpData(pump1State, pump2State);
    delay(5000);
//    previous = current;
//  }
}

void readData()
{
  String endpoint = "http://backend.thinger.io/v3/users/210015364/devices/MyDevice/properties/data?";
  endpoint += "authorization=";
  endpoint += "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJEZXZpY2VDYWxsYmFja19NeURldmljZSIsInN2ciI6ImFwLXNvdXRoZWFzdC5hd3MudGhpbmdlci5pbyIsInVzciI6IjIxMDAxNTM2NCJ9.j0FUi6iUhQwf78P5mODaTA2pUyfIF3GE_VjOlbaw-S8";

  //HTTP Get method
  http.begin(endpoint); // Specify the URL
  int httpCode = http.GET(); //Mak`e the request
  if (httpCode >0)  //check for the returning code
  {
    String payload = http.getString();
    Serial.print("HTTP response code");
    Serial.println(httpCode);
    // Serial.println(payload);

    JSONVar jsonResult = JSON.parse(payload);
    Serial.println(jsonResult["value"]);
    
    pump1Level = int(jsonResult["value"]["humidPlant1"]);
    pump2Level = int(jsonResult["value"]["humidPlant2"]);
  }
  else
  {
    Serial.println("Error on HTTP request");
  }
  http.end(); //Free the resources

  Serial.println();
}

void postPumpData(int Val1, int Val2)
{
    String endpoint = "https://backend.thinger.io/v3/users/210015364/devices/MyDevice/callback/data";

  Serial.println("Sending request...");
  Serial.println(endpoint);

  http.begin(endpoint);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJEZXZpY2VDYWxsYmFja19NeURldmljZSIsInN2ciI6ImFwLXNvdXRoZWFzdC5hd3MudGhpbmdlci5pbyIsInVzciI6IjIxMDAxNTM2NCJ9.j0FUi6iUhQwf78P5mODaTA2pUyfIF3GE_VjOlbaw-S8");

  JSONVar myJsonData;
  myJsonData["pump1"] = Val1;
  myJsonData["pump2"] = Val2;

  String httpRequestData = JSON.stringify(myJsonData);
  Serial.println(httpRequestData);

  int httpCode = http.POST(httpRequestData);
  Serial.print("HTTP response code");
  Serial.println(httpCode);
  http.end();

  Serial.println();
  Serial.println();
}
