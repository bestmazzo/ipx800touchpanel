#include <EEPROM.h>
#include "EEPROMAnything.h"

/*
Config locations:
0->10*sizeof(IPX800conf) : boards config
10*sizeof(IPX800conf)->sizeof(tsConfig) : global config

*/

#define EEPROM_START 25
  
void loadConfig(){
  int pos=EEPROM_START;
  for (int i=0;i<IPX_MAXBOARDNUM;i++) {
    EEPROM_readAnything(pos, ipxConfig[i]);
    pos+=sizeof(IPX800conf);
  }
  EEPROM_readAnything(pos,IPX800TSconf);
  pos+=sizeof(tsConfig);
}

void saveConfig(){
  int pos=EEPROM_START;
  for (int i=0;i<IPX_MAXBOARDNUM;i++) {
    EEPROM_writeAnything(pos, ipxConfig[i]);
    pos+=sizeof(IPX800conf);
  }
  EEPROM_writeAnything(pos,IPX800TSconf);
  pos+=sizeof(tsConfig);
}

void setConfig(char * item, char * value){
 String strItem= item;
 
// Serial.print(item);
// Serial.print("->");
// Serial.println(value);
 byte * pippo = (byte *) malloc(4);
 if (strItem == "mac") {
    Serial.println(value);
    strMac2byteVect(value, IPX800TSconf.mac);
 }
 else if (strItem == "ip") {
   strIp2byteVect(value,pippo);
   IPX800TSconf.ip=IPAddress(pippo);
 }
 else if (strItem == "netmask"){
   strIp2byteVect(value,pippo);
   IPX800TSconf.netmask=IPAddress(pippo);
 }
 else if (strItem == "gateway"){
   strIp2byteVect(value,pippo);
   IPX800TSconf.gateway=IPAddress(pippo);
 }
 else if (strItem == "dns"){
   strIp2byteVect(value,pippo);
   IPX800TSconf.nameserver=IPAddress(pippo);
 }
 else if (strItem == "wait"){
  IPX800TSconf.httpRXwait=atoi(value);
 }
 else if(strItem == "dhcp")
   IPX800TSconf.enableDHCP=atoi(value);
 free(pippo);
}

void showConfig(){
    testo = "mac: ";
    for (int i=0;i<6; i++){
      testo += (String) IPX800TSconf.mac[i];
     if (i<5) testo += ':';
    }
    //sp(testo);
    testo += "\nip:" +  iptostring(IPX800TSconf.ip);
    Serial.println(testo);
    testo ="netmask:" + iptostring(IPX800TSconf.netmask);
    Serial.println(testo);
    testo = "gateway:" + iptostring(IPX800TSconf.gateway);
    Serial.println(testo);
    testo = "dns:" + iptostring(IPX800TSconf.nameserver);
//    sp(testo);      
    testo += "\nDHCP: " + (String) IPX800TSconf.enableDHCP + "\nwait: " + (String) IPX800TSconf.httpRXwait;
    Serial.println(testo);
 
    for (int i=0; i<IPX_MAXBOARDNUM; i++){
        testo = (String) i + ':' + (String) ipxConfig[i].enabled + ':' + iptostring(ipxConfig[i].ip);
        Serial.println(testo);
    }
    ipStr="";
}
