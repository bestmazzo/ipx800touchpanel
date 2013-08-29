//int pbl=0;
//String pippo="";
String testo="";
/*
void cleanIPX(int id){
  ipx[curPoll].id=id;
  for (int i=0;i<8;i++) {
    ipx[curPoll].l[i]=-1;
    ipx[curPoll].d[i]=-1;
  if (i<4) ipx[curPoll].a[i]=0;
  }
}
*/

void ipxCmd(int arg1 , int arg2 , int arg3 ){
//Serial.println(arg1,DEC);Serial.println(arg2,DEC);Serial.println(arg3,DEC);
  if (arg1 >= 0 && ipxConfig[arg1].enabled > 0){
    testo="status.xml";   
    //    Serial.println(iptostring(address));
    // Serial.print("IPX Querying: ");
    // Serial.println(iptostring(remoteip));
    if (arg3 != -1) {// hurge a relay to do something!
      switch (arg3){
      case 0: 
      case 1: 
        testo="preset.htm?led" + String(arg2) + '=' + String(arg3); 
        break; // turn off 
//        req="preset.htm?led" + String(arg2) + "=1"; 
//        break; //turn on
      case 2: 
       testo="leds.cgi?led=" + String(arg2-1); 
        break; // switch
      case 3: 
        testo="rlyfs.cgi?rlyf=" + String(arg2-1); 
        break; // fugitif - pulse
      }

      HTTPget(ipxConfig[arg1].ip,testo,80,1);
      curPoll=arg1;
    }
    else { // get status of the whole board
      ipx[arg1].modA = false;
      ipx[arg1].modL = false;
      ipx[arg1].modD = false;
      HTTPget(ipxConfig[arg1].ip, testo, 80, 0);
      printIPX(); 
      if (curPoll == 0 ) printTime();
    }
    //pippo="";
    //      Serial.println("done");
  }
  else { // function called without params: scan for board.
  // discoverIPX();
  }
}

void discoverIPX(){

    char tmp[] = "Discovery: Who is out there?\0";
    //   Serial.println(tmp);
    // packet ready,send it and hope for the best!
    Udp.beginPacket(IPAddress(255, 255, 255, 255),  30303);
    Udp.write(tmp);
    Udp.endPacket();
    delay(500);
    recvIPXdiscoverPacket();    
}

#include "EthernetUdp.h"
#define UDP_PACKET_SIZE 48

char packetBuffer[UDP_PACKET_SIZE]; //buffer to hold incoming and outgoing packets 

void recvIPXdiscoverPacket(){
  unsigned int rport;
  IPAddress remoteip;
  while (Udp.parsePacket()){
//    Serial.println(Udp.parsePacket(),DEC); // packet size
//    memset(packetBuffer, 0, UDP_PACKET_SIZE); 
    Udp.read(packetBuffer, UDP_PACKET_SIZE);
    remoteip = Udp.remoteIP();  // read the packet into the buffer
    rport = Udp.remotePort();
    sp(iptostring(remoteip));
    Serial.println(packetBuffer);
    delay(10);
  }
}

void pollIPX(){
  if (ipxConfig[curPoll].enabled > 0 ) {
    //Serial.print("Running poller"); 
    //Serial.println(curPoll,DEC);
    ipxCmd(curPoll,-1,-1);
  } 
  curPoll=(curPoll+1) % 10 ;
}

void printIPX(){
  if (millis() < 10000) ipx[curPoll].modL = ipx[curPoll].modD = ipx[curPoll].modA = 1;
  if (ipx[curPoll].modL) printRelay();
  if (ipx[curPoll].modA) printAnalog();
  if (ipx[curPoll].modD) printDigital();
}

void printDigital(){
   testo =  String(curPoll) + ":d:";
    for (int i=0;i<8;i++) 
      testo +=  (String) ipx[curPoll].d[i] +  ",";
      Serial.println(testo);
}

void printRelay(){
    testo = String(curPoll) + ":l:";
    for (int i=0;i<8;i++) 
      testo +=  (String) ipx[curPoll].l[i] + ",";
    Serial.println(testo);
}

void printAnalog(){
    testo =  String(curPoll) + ":a:";
    for (int i=0;i<4;i++) 
      testo +=  (String) ipx[curPoll].a[i] + ',';
    Serial.println(testo);
}

void printTime(){
    testo = String(curPoll) + ":t:" + String(timeStr);
    Serial.println(testo);
}


