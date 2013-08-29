


#include <SPI.h>
#include <Ethernet.h>
#include <Udp.h>
#include <EEPROM.h>
//#include <Dhcp.h>

//#include <TinyXML.h>
//#include <avr/pgmspace.h>


#define HOST_NAME "IPX800ts1"

byte remoteip[]={
  255, 255, 255, 255};
UDP Udp;

//TinyXML xml;
uint8_t buffer[150];
uint16_t buflen = 150;

char timeStr[10]= {
  '\0','\0','\0','\0','\0','\0','\0','\0','\0','\0'};
unsigned int curPoll=0;

#define TELNETPORT 23

//

Server telnetserver(TELNETPORT);
Client client(3); // = Client();		// declare an inactive client

#define COMBUFLEN 100
#define XMLLINELEN 50
// buffer for commandline parsing
char combuf[COMBUFLEN];
char xmlLine[XMLLINELEN];

struct tsConfig{
  char name[16];
  byte mac[6];
  boolean enableDHCP;
  byte ip[4];
  byte netmask[4];
  byte gateway[4];
  byte nameserver[4];
} 
IPX800TSconf;


void setup() {
  //  xml.init((uint8_t*)&buffer,buflen,&XML_callback);

  Serial.begin(57600);
  loadConfig();

  /*
   if (IPX800TSconf.enableDHCP == 1 && Ethernet.begin(IPX800TSconf.mac)){
   IPX800TSconf.ip = Ethernet.localIP();
   IPX800TSconf.netmask = Ethernet.subnetMask();
   IPX800TSconf.gateway = Ethernet.gatewayIP();
   IPX800TSconf.nameserver = Ethernet.dnsServerIP();
   }
   else
   */
  Ethernet.begin(IPX800TSconf.mac, IPX800TSconf.ip, IPX800TSconf.gateway, IPX800TSconf.netmask);
  //  Serial.print("OK");
  telnetserver.begin();
  Udp.begin(8888);
  memset(combuf, 0, COMBUFLEN);  
  //memset(xmlLine, 0, XMLLINELEN);

}


void loop(void) {
  client = telnetserver.available();
  while (Serial.available())
    readCommand(Serial.read());
  if (client)
    readCommand(client.read());
  pollIPX();
}


