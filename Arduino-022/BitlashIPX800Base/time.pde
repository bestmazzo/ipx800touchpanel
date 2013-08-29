#include "bitlash.h"
#include "Time.h"
//#include "TimeAlarms.h"


void CronAlarms(){
  if (lt.Year != ct.Year)
     ifdoCommand("onyear");
  if (lt.Month != ct.Month)
     ifdoCommand("onmonth");
  if (lt.Day != ct.Day)
     ifdoCommand("onday");
  if (lt.Hour != ct.Hour){
     sendNTPpacket(ntpip); delay(500); recvNTPpacket();
     ifdoCommand("onhour");
  }
  if (lt.Minute != ct.Minute)
     ifdoCommand("onminute");
  if (lt.Second != ct.Second)
     ifdoCommand("onsecond");
  if (lt.Wday >  ct.Wday ) 
     ifdoCommand("onweek");
}

#include "Udp.h"
#define UDP_PACKET_SIZE 48

byte packetBuffer[UDP_PACKET_SIZE]; //buffer to hold incoming and outgoing packets 
// send an NTP request to the time server at the given address 
unsigned long sendNTPpacket(byte *address)
{
  // set all bytes in the buffer to 0
  memset(packetBuffer, 0, UDP_PACKET_SIZE); 
  // Initialize values needed to form NTP request
  // (see URL above for details on the packets)
  packetBuffer[0] = 0b11100011;   // LI, Version, Mode
  packetBuffer[1] = 0;     // Stratum, or type of clock
  packetBuffer[2] = 6;     // Polling Interval
  packetBuffer[3] = 0xEC;  // Peer Clock Precision
  // 8 bytes of zero for Root Delay & Root Dispersion
  packetBuffer[12]  = 49; 
  packetBuffer[13]  = 0x4E;
  packetBuffer[14]  = 49;
  packetBuffer[15]  = 52;

  // all NTP fields have been given values, now
  // you can send a packet requesting a timestamp: 
  // Serial.print("About to send NTP request!.");		   
  Udp.sendPacket( packetBuffer, UDP_PACKET_SIZE,  address, 123); //NTP requests are to port 123
//  Serial.println("..done!");
}

unsigned long recvNTPpacket(){
  if ( Udp.available() ) {  
    Udp.readPacket(packetBuffer, UDP_PACKET_SIZE);  // read the packet into the buffer

    //the timestamp starts at byte 40 of the received packet and is four bytes,
    // or two words, long. First, esxtract the two words:

    unsigned long highWord = word(packetBuffer[40], packetBuffer[41]);
    unsigned long lowWord = word(packetBuffer[42], packetBuffer[43]);  
    // combine the four bytes (two words) into a long integer
    // this is NTP time (seconds since Jan 1 1900):
    unsigned long secsSince1900 = highWord << 16 | lowWord;  
    
    // now convert NTP time into everyday time:
    //Serial.print("Unix time = ");
    // Unix time starts on Jan 1 1970. In seconds, that's 2208988800:
    const unsigned long seventyYears = 2208988800UL;     
    // subtract seventy years:
    unsigned long epoch = secsSince1900 - seventyYears + TimeZoneOffset*3600;  
    //Serial.println(epoch);
    // save epoch into Bitlash
    setTime(epoch);
    Serial.println(epoch,DEC);
    }
}

