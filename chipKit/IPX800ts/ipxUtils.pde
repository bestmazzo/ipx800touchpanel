int pbl=0;
String pippo="";

void cleanIPX(int id){
  ipx.id=id;
  for (int i=0;i<8;i++) {
    ipx.l[i]=-1;
    ipx.d[i]=-1;
  if (i<4) ipx.a[i]=0;
}
}


int ipxCmd(int arg1, int arg2, int arg3){
//Serial.println(arg1,DEC);Serial.println(arg2,DEC);Serial.println(arg3,DEC);
  if (arg1 >= 0 && ipxConfig[arg1].enabled > 0){
    byte* address=ipxConfig[arg1].ip;  
    
    //    Serial.println(iptostring(address));
    int mode;
    int usingled=0;
    // Serial.print("IPX Querying: ");
    // Serial.println(iptostring(remoteip));
    if (arg3 != -1) {// hurge a relay to do something!
      usingled = arg2;
      mode = arg3;
      switch (mode){
      case 0: 
        pippo="preset.htm?led" + String(usingled) + "=0"; 
        break; // turn off
      case 1: 
        pippo="preset.htm?led" + String(usingled) + "=1"; 
        break; //turn on
      case 2: 
        pippo="leds.cgi?led=" + String(usingled-1); 
        break; // switch
      case 3: 
        pippo="rlyfs.cgi?rlyf=" + String(usingled-1); 
        break; // fugitif - pulse
      }

      HTTPget(address,pippo,80,1);
      curPoll=arg1;
    }
    else if (arg2 != -1) { // get status of some data
      //               pippo="status.xml"; 
      //               usingled = getarg(2);
      //               hm=0;
      //               type = usingled / 10;
      //               switch (type){
      //                 case 0: searchtype='L'; break;
      //                 case 1: searchtype='A'; break;
      //                 case 2: searchtype='B'; break;
      //                 case 3: searchtype='T'; break;
      //               }
      //               HTTPget(address, pippo, 80, hm);
      //               break;
    }
    else { // get status of the whole board
      HTTPget(address, "status.xml", 80, 0);
    }
    //pippo="";
    //      Serial.println("done");
  }
  else { // function called without params: scan for board.

    char tmp[] = "Discovery: Who is out there?\0";
    Serial.println(tmp);

    //for (int i=0;i<sizeof(tmp);i++)
    //  packetBuffer[i] = tmp[i];

    // packet ready,send it and hope for the best!
 /*   Udp.beginPacket(IPAddress(255, 255, 255, 255),  30303);
    Udp.write(tmp);
    Udp.endPacket();
    delay(1000);
    recvIPXdiscoverPacket();
  */
  }
}

//#include "EthernetUdp.h"
#define UDP_PACKET_SIZE 48

char packetBuffer[UDP_PACKET_SIZE]; //buffer to hold incoming and outgoing packets 
/*
unsigned long recvIPXdiscoverPacket(){
  unsigned int rport;
  while (Udp.parsePacket()){
    Serial.println(Udp.parsePacket(),DEC);
//    memset(packetBuffer, 0, UDP_PACKET_SIZE); 
    Udp.read(packetBuffer, UDP_PACKET_SIZE);
    remoteip = Udp.remoteIP();  // read the packet into the buffer
    rport = Udp.remotePort();
    Serial.println(packetBuffer);
    delay(10);
  }
}
*/
void pollIPX(){
  if (ipxConfig[curPoll].enabled > 0) {
    //Serial.print("Running poller"); 
    //Serial.println(curPoll,DEC);
    ipxCmd(curPoll,-1,-1);
  } 
  curPoll=(curPoll+1) % 10 ;
}

void printIPX(){
  Serial.print(ipx.id,DEC); Serial.print(":l:");
  for (int i=0;i<8;i++) {
    Serial.print(ipx.l[i],DEC); Serial.print(','); }
  Serial.println(); Serial.print(ipx.id,DEC); Serial.print(":a:");
  for (int i=0;i<4;i++) {
    Serial.print(ipx.a[i],DEC); Serial.print(','); }
  Serial.println(); Serial.print(ipx.id,DEC); Serial.print(":d:");
  for (int i=0;i<8;i++) {
    Serial.print(ipx.d[i],DEC); Serial.print(','); }
  Serial.println();
  Serial.print(ipx.id,DEC); Serial.print(":t:");
  Serial.println(timeStr);
 // sp(memtest(5),DEC);
//  spln();
}


void arduinoStatus(){
  sp(-10,DEC); sp(":m:"); sp(memtest(5),DEC);
  spln();
  
}

