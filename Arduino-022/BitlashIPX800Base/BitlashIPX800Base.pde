//////////////////////////////////////////////////////////////////
//
//	bitlashtelnet2.pde:	Bitlash Telnet Server for the Ethernet Shield
//
//	Copyright 2011 by Bill Roy
//
//	Permission is hereby granted, free of charge, to any person
//	obtaining a copy of this software and associated documentation
//	files (the "Software"), to deal in the Software without
//	restriction, including without limitation the rights to use,
//	copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the
//	Software is furnished to do so, subject to the following
//	conditions:
//	
//	The above copyright notice and this permission notice shall be
//	included in all copies or substantial portions of the Software.
//	
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//	OTHER DEALINGS IN THE SOFTWARE.
//
//////////////////////////////////////////////////////////////////
//
#include <SPI.h>
#include <Ethernet.h>
#include "Time.h"
//#include "TimeAlarms.h"
#include "Udp.h"
#include "bitlash.h"

////////////////////////////////////////
//
//	Ethernet configuration
//	Adjust for local conditions
//
byte mac[] 		= {'b','i','t','l','s','h'};

byte ip[] = {192, 168, 2, 13};
byte gateway[]	= {192, 168, 2, 254};
byte netmask[]	= {255, 255, 255, 0};
byte remoteip[] ={255, 255, 255, 255};
byte ntpip[] ={192, 43, 244, 18};

int TimeZoneOffset = 2;
tmElements_t lt; // local time
tmElements_t ct; //current time
time_t epoch;

#define TELNETPORT 23
//
////////////////////////////////////////

Server telnetserver = Server(TELNETPORT);
Client client(MAX_SOCK_NUM);		// declare an inactive client

// link functions defined elsewhere
// extern void setCronAlarms();

void setup(void) {
  
        blSetup();
 //       setCronAlarms();
}


void loop(void) {
      blLoop();
      epoch = now(); // gets current time
      breakTime(epoch,ct);
//      CronAlarms();
      breakTime(epoch,lt); // updates time struct for future comparisons
}
