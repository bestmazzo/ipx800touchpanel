#include <EEPROM.h>
#include "EEPROMAnything.h"

/*
Config locations:
0->10*sizeof(IPX800conf) : boards config
10*sizeof(IPX800conf)->sizeof(tsConfig) : global config

*/

#define EEPROM_STARTPOS 25 
  
void initConfig(){
    IPX800TSconf.enableDHCP = 0;
    IPX800TSconf.mac = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xBE };
    IPX800TSconf.ip = {192, 168, 2, 144};
    IPX800TSconf.netmask = {255,255,255,0};
    IPX800TSconf.gateway = {192,168,2,254};
    IPX800TSconf.nameserver = {192,168,2,254};
    saveConfig();
}

void loadConfig(){
  int pos=EEPROM_STARTPOS;
  int inited;
  EEPROM_readAnything(pos-sizeof(inited), inited);
  if (!inited) initConfig();
  for (int i=0;i<IPX_MAXBOARDNUM;i++) {
    EEPROM_readAnything(pos, ipxConfig[i]);
    pos+=sizeof(IPX800conf);
  }
  EEPROM_readAnything(pos,IPX800TSconf);
  pos+=sizeof(tsConfig);
}

void saveConfig(){
  int pos=EEPROM_STARTPOS;
  int inited = 1;
  EEPROM_writeAnything(pos-sizeof(inited), inited);
  for (int i=0;i<IPX_MAXBOARDNUM;i++) {
    EEPROM_writeAnything(pos, ipxConfig[i]);
    pos+=sizeof(IPX800conf);
  }
  EEPROM_writeAnything(pos,IPX800TSconf);
  pos+=sizeof(tsConfig);
}

void setConfig(char * item, char * value){
 String strItem= item;
 byte * pippo = (byte *) malloc(4);
 if (strItem == "mac")
    strMac2byteVect(value, IPX800TSconf.mac);
 else if (strItem == "ip") {
   strIp2byteVect(value,pippo);
   memcpy(IPX800TSconf.ip, pippo,4);
 }
 else if (strItem == "netmask"){
   strIp2byteVect(value,pippo);
   memcpy(IPX800TSconf.netmask,pippo,4);
 }
 else if (strItem == "gateway"){
   strIp2byteVect(value,pippo);
   memcpy(IPX800TSconf.gateway,pippo,4);
 }
 else if (strItem == "dns"){
   strIp2byteVect(value,pippo);
   memcpy(IPX800TSconf.nameserver,pippo,4);
 }
 else if(strItem == "dhcp")
   IPX800TSconf.enableDHCP=atoi(value);
 free(pippo);
}

void showConfig(){
  if (client && client.connected()){
    client.print("mac: ");
    for (int i=0;i<6; i++){
      client.print((int) IPX800TSconf.mac[i], HEX);
     if (i<5) client.print(":");
    }
    client.println();
    client.print("ip:"); client.println(iptostring(IPX800TSconf.ip));
    client.print("netmask:"); client.println(iptostring(IPX800TSconf.netmask));
    client.print("gateway:"); client.println(iptostring(IPX800TSconf.gateway));
    client.print("nameserver:"); client.println(iptostring(IPX800TSconf.nameserver));
    client.print("DHCP: "); client.println(IPX800TSconf.enableDHCP,DEC);
  }
}

void serialConfig(){
    Serial.print("mac: ");
    for (int i=0;i<6; i++){
      Serial.print(IPX800TSconf.mac[i],HEX);
     if (i<5) Serial.print(":");
    }
    Serial.println();
    Serial.print("ip:"); Serial.println(iptostring(IPX800TSconf.ip));
    Serial.print("netmask:"); Serial.println(iptostring(IPX800TSconf.netmask));
    Serial.print("gateway:"); Serial.println(iptostring(IPX800TSconf.gateway));
    Serial.print("nameserver:"); Serial.println(iptostring(IPX800TSconf.nameserver));
    Serial.print("DHCP: "); Serial.println(IPX800TSconf.enableDHCP,DEC);
    for (int i=0; i<IPX_MAXBOARDNUM; i++){
        Serial.print(i,DEC); Serial.print(":");
        Serial.print(ipxConfig[i].enabled,DEC); Serial.print(":");
        Serial.println(iptostring(ipxConfig[i].ip));
    }
}
