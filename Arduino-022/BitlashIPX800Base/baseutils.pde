#include "bitlash.h"
extern void sp(const char *);
extern void spb(char);
extern void speol();

void HTTPget(byte* address, String page, int port, int mode){
  Client machine(address, port);
//  sp(iptostring(address));
  if (machine.connect()){
      String request = "GET /" + page + " HTTP/1.0";
      machine.println(request);
      machine.println();
 //   Serial.println(request);
      if (mode==0){
        delay(200);
          while (machine.available())
            if( IPXprocessResponse((char) machine.read()) >0 )break;
      }
    machine.flush();
    machine.stop(); 
 }
 else   sp("E:ConFail");
}

/*
 * Ritorna un vettore di 4 byte ottenuto dalla stringa str
 * rappresentante un indirizzo ip.
 * Ritorna null nel caso in cui str non rappresenta un indirizzo ip.
 */
//byte *strIp2byteVect(String str){
//  String tmpStr;
//  int bytesCount,			 //contatore per il num di byte
//	i;				    //contatore per il ciclo sulla stringa
//  byte ipVect[] = {0,0,0,0};
//  
//  i = 0;
//  for (bytesCount = 0; bytesCount < 4; bytesCount++){     //Ciclo sui byte
//    for ( ; (str.charAt(i) != '.') && (str.charAt(i) != '\0'); i++)  //Ciclo sulla stringa
//	tmpStr += str.charAt(i);
//    ipVect[bytesCount] = tmpStr.toInt();
////    tmpStr = "";
//    ++i;
//  }
//  
//  if (bytesCount != 4){
//    return NULL;
//  }
//  return ipVect;
//}

String iptostring(byte *b){
  String ipStr="";
  for (int i = 0; i < 4; ++i)
    if (i < 3)
      ipStr += String((long)b[i]) + ".";
    else
      ipStr += String((long)b[i]);
  return ipStr;
}

void mergeip(byte *src, byte*dst){
  for (int i=0;i<4;i++)
        dst[i]=src[i];
}
      

