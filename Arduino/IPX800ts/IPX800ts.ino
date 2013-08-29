
#include <SPI.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include <Dhcp.h>

#define HOST_NAME "IPX800ts1"

//IPAddress remoteip(255, 255, 255, 255);
EthernetUDP Udp;

char timeStr[10]={0,0,0,0,0,0,0,0,0,0};
unsigned int curPoll=0;

#define TELNETPORT 23
//EthernetServer telnetserver = EthernetServer(TELNETPORT);

//EthernetClient client(MAX_SOCK_NUM);		// declare an inactive client

#define COMBUFLEN 30
#define XMLLINELEN 50
// buffer for commandline parsing
char combuf[COMBUFLEN];
char xmlLine[XMLLINELEN];

#define IPX_MAXBOARDNUM 8

struct IPX800data{
  int l[8];
  int a[4];
  int d[8];
  boolean modL;
  boolean modA;
  boolean modD;
} ipx[IPX_MAXBOARDNUM];

struct tsConfig{
  char name[16];
  byte mac[6];
  boolean enableDHCP;
  IPAddress ip;
  IPAddress netmask;
  IPAddress gateway;
  IPAddress nameserver;
  int httpRXwait;
} IPX800TSconf;


void setup() {
  Serial.begin(57600);
  loadConfig();
 byte mac[] =  {0x90, 0xa2, 0xda, 0x00, 0x6b, 0x64 };
  memcpy(IPX800TSconf.mac,mac,6);
//  showConfigToSerial();
//  IPX800TSconf.enableDHCP =0 ;
  if (IPX800TSconf.enableDHCP == 1 && Ethernet.begin(IPX800TSconf.mac)){
    IPX800TSconf.ip = Ethernet.localIP();
    IPX800TSconf.netmask = Ethernet.subnetMask();
    IPX800TSconf.gateway = Ethernet.gatewayIP();
    IPX800TSconf.nameserver = Ethernet.dnsServerIP();
  }
  else 
  Ethernet.begin(IPX800TSconf.mac, IPX800TSconf.ip, IPX800TSconf.nameserver, IPX800TSconf.gateway, IPX800TSconf.netmask);
//   Serial.println("OK");
//  telnetserver.begin();
  Udp.begin(8888);
  memset(combuf, 0, COMBUFLEN);  
  memset(xmlLine, 0, XMLLINELEN);
  memset(ipx,0, IPX_MAXBOARDNUM*sizeof(IPX800data));  
}

void loop(void) {
//  client = telnetserver.available();
    while (Serial.available())
    readCommand(Serial.read());
//  while (client.connected() && client.available())
//    readCommand(client.read());
  pollIPX();
}


