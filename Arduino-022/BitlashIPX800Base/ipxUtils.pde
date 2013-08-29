#include "bitlash.h"


char processBuffer[30];
int pbl=0;
int usingled=0;

char searchtype = 'L';

int IPXprocessResponse(char in){
  int i=0;
  if (in == '\n'){
    processBuffer[pbl]='\0';
    i = processResponseLine();
    pbl=0;
  }
   else if (pbl<29) processBuffer[pbl++]=in;  
  return i;
}

int processResponseLine(){
    String src(processBuffer);
    String tmp;
    switch (searchtype){
      case 'L': tmp="led"; tmp += usingled-1; break;
      case 'T': tmp="time0"; break;
      case 'A': tmp="an"; tmp+=usingled; break;
      case 'B': tmp="btn"; tmp+=usingled-1; break;
      case '*': tmp="<"; break;
    }
    int p=src.indexOf(tmp);
    int q;
    String ssrc;
//   Serial.println(processBuffer);
//    Serial.print(search); Serial.println(p); 
    if (p > 0){
      switch (searchtype){
        case 'L':
        case 'B':  spb(src[p+5]); speol(); break;
        case 'A':  ssrc="</an";
                   q=src.indexOf(ssrc);
                   for (; p<q; p++)  { spb(src[p]); speol(); }
                   break;
         case '*': ssrc="</";
                   q=src.indexOf(ssrc);
                   for (; p<q; p++) {spb(src[p]); speol(); }
                   break;
         case 'T': for (int i=7; i<15; i++) { spb(src[i]); speol();} 
                   break;
      }
      return 1;
    }
    return 0;
}

numvar ipxCmd(){
  if (getarg(0) > 0){
    byte address[4]; address[0] = ip[0]; address[1]= ip[1];  address[2]= ip[2]; address[3]= getarg(1);  
 //   Serial.println(iptostring(address));
    int hm=1; // default: don't get http responses    
    String pippo;
    int mode;
    int type=0;
   // Serial.print("IPX Querying: ");
   // Serial.println(iptostring(remoteip));
    switch (getarg(0)){
      case 3: // hurge a relay to do something!
              usingled = getarg(2);
              mode = getarg(3);
              switch (mode){
                case 0: pippo="preset.htm?led" + String(usingled)  + "=0"; break; // turn off
                case 1: pippo="preset.htm?led" + String(usingled) + "=1"; break; //turn on
                case 2: pippo="leds.cgi?led=" + String(usingled-1); break; // switch
                case 3: pippo="rlyfs.cgi?rlyf=" + String(usingled-1); break; // fugitif - pulse
              }
              HTTPget(address,pippo,80,hm);
              break;
       case 2: // get status of some data
               pippo="status.xml"; 
               usingled = getarg(2);
               hm=0;
               type = usingled / 10;
               switch (type){
                 case 0: searchtype='L'; break;
                 case 1: searchtype='A'; break;
                 case 2: searchtype='B'; break;
                 case 3: searchtype='T'; break;
               }
               HTTPget(address, pippo, 80, hm);
               break;
       case 1: // get status of the whole board
               searchtype='*'; 
               pippo="status.xml"; 
               hm=0;
               HTTPget(address, pippo, 80, hm);
               break;
    }
      pippo="";
//      Serial.println("done");
  }
  else { // function called without params: scan for board.
    remoteip[0]=remoteip[1]=remoteip[2]=remoteip[3]=255;
    sendIPXdiscoverPacket(remoteip);
    delay(1000);
    recvIPXdiscoverPacket();
  }

}

#include "Udp.h"
#define UDP_PACKET_SIZE 48

extern byte packetBuffer[UDP_PACKET_SIZE]; //buffer to hold incoming and outgoing packets 

// send an NTP request to the time server at the given address 
unsigned long sendIPXdiscoverPacket(byte *address)
{
  // set all bytes in the buffer to 0
  memset(packetBuffer, 0, UDP_PACKET_SIZE); 
  // Initialize values needed to form NTP request
  // (see URL above for details on the packets)
  
  char tmp[48] = "Discovery: Who is out there?\0";
  sp(tmp);
  for (int i=0;i<sizeof(tmp);i++)
    packetBuffer[i] = tmp[i];
  
  // packet ready,send it and hope for the best!
  Udp.sendPacket( packetBuffer,sizeof(tmp),  address,  30303); 
}

unsigned long recvIPXdiscoverPacket(){
  unsigned int rport;
  int i = Udp.available();
  if (i ==0) sp("E:NoResp");
  while ( i ) {  
    memset(packetBuffer, 0, UDP_PACKET_SIZE); 
      Udp.readPacket((char*)packetBuffer, i, remoteip, rport);  // read the packet into the buffer
    // try something clever to do now...
    Serial.println(iptostring(remoteip));
    sp((char *) packetBuffer);
    i = Udp.available();
  }
}

