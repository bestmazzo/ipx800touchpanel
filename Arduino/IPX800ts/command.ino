
struct CMDargs_t{
  int argc;
  char* argv[10];
};

int bufpos=0;
int xmlbufpos=0;

CMDargs_t arguments;

struct IPX800conf{
  IPAddress ip;
  boolean enabled;
} ipxConfig[IPX_MAXBOARDNUM];

void sp(String &msg, int mode = 0){
// mode : 0 = serial, 1=both, 2= net  
  if (mode < 2) Serial.println(msg);
//  if (mode > 0 && client && client.connected())
//     telnetserver.println(msg);
}

void parseCmdLine(){
  String tmp=combuf;
// Serial.println(tmp);
  int a=tmp.indexOf('(');
  if ( a != -1) {
    memset(&arguments, 0, sizeof(CMDargs_t));
    char * curArg = (char *) malloc(a+1);
    memcpy(curArg,combuf,a);
    curArg[a]='\0';
    arguments.argv[0]=curArg;
    arguments.argc=0;
//  Serial.print(curArg);
//  Serial.print(":");
    int cond=1;
    while(cond){
      int b = tmp.indexOf(',',a+1);
      if (b == -1) { 
        b = tmp.indexOf(')'); 
        cond=0; 
        if (b-a == 1) continue;  //empty field!
        }
      curArg = (char *) malloc(b-a);
      for (int i=a+1; i<b; i++)
        curArg[i-a-1] = combuf[i];
      curArg[b-a-1]='\0';
      arguments.argc++;
      arguments.argv[arguments.argc]=curArg;
//    Serial.print(a,DEC); Serial.print("-");Serial.println(b,DEC);
//    Serial.println(arguments.argv[arguments.argc]); Serial.println(",");
      a=b;
    }  
  }
  //tmp="";
  // return argum;  
}

void readCommand(char c){
  //   Serial.print(':');Serial.print(c);
 // if ( client && client.connected()) client.print(c);
  if (c == '\n') {
    parseCmdLine();
    parseLine();    
    memset(combuf, 0, 100);
    bufpos=0;
  }
  else {
    combuf[bufpos++]=c;
  }
}


void parseLine(){

 // Serial.println(arguments.argv[0]);
  String tmp = arguments.argv[0];
  if ( tmp == "ipx" ){
 //   Serial.println("IPX!!!");
    int a[3]={ -1, -1, -1 };
    for( int i=0; i<arguments.argc; i++) {
      a[i]=atoi(arguments.argv[i+1]);
   //   Serial.println(a[i]);
    }
    ipxCmd(a[0], a[1], a[2]);
 //   tmp = "ipx(" + String(a[0]) + "," + String(a[1]) + "," + String(a[2]) + ")";
  //  if (client && client.connected()) {
  //    client.println(tmp);
  //  }
 //   Serial.println(tmp);
  }
  else if (tmp == "poll"){
    //Serial.print("$");
    //Serial.println(arguments->argc,DEC);
    if (arguments.argc < 2) return;
    int i = atoi(arguments.argv[1]);
    ipxConfig[i].enabled=atoi(arguments.argv[2]);
    if (arguments.argc == 3) {
      byte * tmpIP= (byte *) malloc(4);
      strIp2byteVect(arguments.argv[3],tmpIP);
      if (tmpIP) {
        //Serial.print("Registering new poller"); 
        //ipxPolling[i].interval= atoi(arguments->argv[2]);
        ipxConfig[i].ip=IPAddress(tmpIP);
        curPoll=i;
        free(tmpIP);
        //Serial.println("DONE!");
      }
    }
  }
 // else if (tmp == "reboot") reboot();
  else if (tmp == "save") saveConfig();
  else if (tmp == "free") Serial.println(memtest(2),DEC);
  else if (tmp == "set") {
     if (arguments.argc == 2)
      setConfig(arguments.argv[1], arguments.argv[2]); 
     else showConfig();
  }
 
  for (int i=0; i<=arguments.argc; i++)
    free(arguments.argv[i]);
 // free(arguments);  //  Serial.print('>');
 // tmp="";
} 

#include <avr/wdt.h>

void reboot() {
  wdt_disable();  
  wdt_enable(WDTO_15MS);
  while (1) {}
}



unsigned int memtest(unsigned short int step) {
	byte *buffer;

	// 16k max
	for (unsigned int i = 16384; i; i -= step) {
		buffer = (byte *)malloc(i);

		if (buffer) {
			free(buffer);
			return i;
		}
	}
} 
