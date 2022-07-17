#include <WiFi.h>
#include <NTPClient.h>
#include <IOXhop_FirebaseESP32.h>


#include "FS.h"
#include "SD.h"
#include "SPI.h"

#define PINLDR 34
#define PINUMIDADE 35
#define PINRELAY 27

#define PINTHERMISTOR 36

const char* ssid;
const char* passwd;

const char* userID;
const char* plantID;

String _SSID;
String _passwd;
String _userID;
String _plantID;

const char* firebaseHost = "https://garden-74604-default-rtdb.firebaseio.com/";
const char* firebaseAuth = "8v2CAxBRqr1bsCAS9u9sBSeGoOe32yEbJinVOyd3";

unsigned long int onTimeFirebase = 0;
float lightMin = 0;
float lightMax = 0;
float moistMin = 0;

WiFiUDP udp;
NTPClient ntp(udp, "a.st1.ntp.br", -3 * 3600, 60000);
unsigned long int onTime = 0;
unsigned long int timerOne = 0;
unsigned long int timerReley = 0;
unsigned long int sendTime = 0;

float moist = 0;
float light = 0;
float temp = 0;

long int t1;
long int t2;

void setup() {
  Serial.begin(115200);
  pinMode(PINLDR, INPUT);
  pinMode(PINTHERMISTOR, INPUT);
  pinMode(PINRELAY, OUTPUT);
  initSDCard();
  readFile(SD, "/conf.txt");
  initConnection();
  startNTP();
  startDatabase();
  turnOnDevice();
}
void loop() {
  if (Firebase.getBool(varPath("situation")) == false) {
    restart("A cultura foi desativada, o sistema vai ser reiniciado!\n");
  }
  if (millis() - timerOne >= 2000) {
    setTemp();
    setLight();
    setMoisture();
    timerOne = millis();
  }

  if (millis() - sendTime >= 80000) {
    sendInfo(getDateNTP());
    sendTime = millis();
  }

  operatingTime();

  if (millis() - timerReley >= 80000) {
    if (moist < moistMin) {
      digitalWrite(PINRELAY, HIGH);
      delay(1000);
      digitalWrite(PINRELAY, LOW);
    } else {
      digitalWrite(PINRELAY, LOW);
    }
    timerReley = millis();
  }
}

void restart(String msg) {
  Serial.printf("%s", msg);
  Serial.println("Reiniciando sistema!");
  delay(500);
  ESP.restart();
}


void initConnection() {
  ssid = _SSID.c_str();
  passwd = _passwd.c_str();

  WiFi.begin(ssid, passwd);
  Serial.print("Conectando no WiFi..");
  while (WiFi.status() != WL_CONNECTED) {
    delay(100);
    Serial.print(".");
  }
  Serial.println("\nConectado!\n");
  delay(50);
}

void startNTP() {
  ntp.begin();
  ntp.forceUpdate();
  Serial.println("\nNTP inicializado!\n");
  delay(50);
}

String getDateNTP() {
  
  time_t epochTime = ntp.getEpochTime();

  int currentHour = ntp.getHours();


  int currentMinute = ntp.getMinutes();


   
  int currentSecond = ntp.getSeconds();

  
  struct tm *ptm = gmtime ((time_t *)&epochTime);

  int monthDay = ptm->tm_mday;

  int currentMonth = ptm->tm_mon + 1;

  int currentYear = ptm->tm_year + 1900;

  String tempDate =  (String)monthDay + "-" + (String)currentMonth + "-" + (String)currentYear + " " + (String)currentHour + ":"+ (String)currentMinute + ":" + (String)currentSecond ;

  return tempDate;
}

void initSDCard() {
  if (!SD.begin()) {
    restart("Não foi possível montar o cartão de memória\n");
  }
  uint8_t cardType = SD.cardType();
  uint64_t cardSize = SD.cardSize() / (1024 * 1024);
  Serial.printf("\nA capacidade do seu cartão de memória é de: %lluMB\n", cardSize);
  delay(50);
}



void readFile(fs::FS &fs, const char * path) {
  String readLine = "";
  char ch;
  int index = 0;

  File file = fs.open(path);
  if (!file) {
    restart("Não foi encontrado o arquivo necessário!\n");
  }

  Serial.print("Lendo o arquivo");
  while (file.available()) {
    ch = file.read();
    if (ch == '\n' && index == 0) {
      _userID = readLine;
      index += 1;
      readLine = "";
    } else if (ch == '\n' && index == 1) {
      _plantID = readLine;
      index += 1;
      readLine = "";
    } else if (ch == '\n' && index == 2) {
      _SSID = readLine;
      index += 1;
      readLine = "";
    } else if (ch == '\n' && index == 3) {
      _passwd = readLine;
      index += 1;
      readLine = "";
    } else {
      readLine += ch;
    }
    delay(50);
    Serial.print(".");
  }
  Serial.println("\nLeitura concluída!\n");
  file.close();
  delay(50);
}

void startDatabase() {
  Firebase.begin(firebaseHost, firebaseAuth);
  Serial.println("Banco de dados conectado!\n");
  delay(50);
}


void turnOnDevice() {
  String title = Firebase.getString(varPath("title"));
  if (Firebase.getBool(varPath("situation")) == false) {
    Firebase.setBool(varPath("situation"), true);
    Serial.printf("Cultura de %s ativada com sucesso!\n", title);
    delay(50);
  }

  Serial.println("Configurando sistema...");
  lightMin = Firebase.getFloat(varPath("lightingMin"));
  delay(50);
  lightMax = Firebase.getFloat(varPath("lightingMax"));
  delay(50);
  moistMin = Firebase.getFloat(varPath("moistureMin"));
  delay(50);
  onTimeFirebase = Firebase.getInt(varPath("timer"));
  delay(50);
  Serial.println("Sistema iniciado com sucesso!");
  delay(100);
}

String varPath(String var) {
  String path = "/" + _userID + "/plants/" + _plantID + "/" + var;
  return path;
}

void setTemp() {
  temp = map(analogRead(PINTHERMISTOR), 0, 4095, 0, 60);
  Serial.println(analogRead(PINTHERMISTOR));
  Firebase.setFloat(varPath("temperature"), temp);
}

void setMoisture() {
  moist = map(analogRead(PINUMIDADE), 4095, 1550, 0, 100);
  if (moist > 100.0) {
    Firebase.setFloat(varPath("moisture"), 100.0);
    moist = 100.0;
  }
  else {
    Firebase.setFloat(varPath("moisture"), moist);
  }
}

void setLight() {
  
  light = map(analogRead(PINLDR), 0, 4095, 0, 100);
  Firebase.setFloat(varPath("lighting"), light);
}

void operatingTime() {
  if ((light >= lightMin)) {
    t1 = abs(millis() - t2);
    onTime = (onTime + t1) / 1000 ;
  } else {
    t2 = abs(millis() - t1);
  }
  if (Firebase.getString(varPath("timeReset")) != getDateNTP()) {
    onTime = 0;
    onTimeFirebase = 0;
  }
  Firebase.setInt(varPath("timer"), (onTime + onTimeFirebase));
  Firebase.setString(varPath("timeReset"), getDateNTP());
}


void sendInfo(String date) {
  Firebase.setString(varPath("register/" + date + "/1"), (date));
  Firebase.setFloat(varPath("register/" + date + "/2"), (moist));
  Firebase.setFloat(varPath("register/" + date + "/3"), (temp));
  Firebase.setFloat(varPath("register/" + date + "/4"), (light));
  Firebase.setInt(varPath("register/" + date + "/5"), (onTime + onTimeFirebase));
}
