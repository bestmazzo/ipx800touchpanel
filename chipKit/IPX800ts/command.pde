//#include <avr/wdt.h>

extern int ipxCmd(int, int, int);

struct CMDargs_t{
  int argc;
  char* argv[10];
};

int bufpos=0;
int xmlbufpos=0;

CMDargs_t arguments;

struct IPX800data{
  int id;
  int l[8];
  int a[4];
  int d[8];
} ipx;

#define IPX_MAXBOARDNUM 10
struct IPX800conf{
  byte ip[4];
  int id;
  int enabled;
} ipxConfig[IPX_MAXBOARDNUM];

String tmp="";
String tagstr="";

void sp(char msg  ){
  Serial.print(msg);
  if (client) 
    telnetserver.print(msg);  
}

void sp(char * msg){
  Serial.print(msg);
 if (client) 
    telnetserver.print(msg);  
}

void sp(int a, int b){
    Serial.print(a,b);
 if (client) 
    telnetserver.print(a,b);  
}

void sp(String& msg){
    Serial.print(msg);
 if (client) 
    telnetserver.print(msg);  
 }

void spln(char *msg){
  sp(msg);
  spln();
}

void spln(){
  sp('\n');
}
/*
void XML_callback( uint8_t statusflags, char* tagName,  uint16_t tagNameLen,  char* data,  uint16_t dataLen ){
  if  (statusflags & STATUS_TAG_TEXT){
    tagstr=tagName; 
    //    Serial.println(tagName);
    if ( tagstr.startsWith("/response/led"))  ipx.l[tagName[13]-48]=atoi(data);
    else if ( tagstr.startsWith("/response/an")) ipx.a[tagName[12]-49]=atoi(data);      
    else if ( tagstr.startsWith("/response/btn")) ipx.d[tagName[13]-48]= (data[0] == 'd');      
    else if ( tagstr.startsWith("/response/time0")) timeStr = data;      
    tagstr="";
  }
}
*/
void parseCmdLine(){
  tmp=combuf;
  // Serial.println(tmp);
  int a=tmp.indexOf('(');
  memset(&arguments, 0, sizeof(CMDargs_t));
  char * curArg = (char *) malloc(a+1);
  memcpy(curArg,combuf,a);
  curArg[a]='\0';
  arguments.argv[0]=curArg;
  arguments.argc=0;
  // Serial.print(curArg);
  // Serial.print(":");
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
  //  Serial.print(a,DEC); Serial.print("-");Serial.println(b,DEC);
  //  Serial.println(arguments->argv[arguments->argc]); Serial.println(",");
    a=b;
  }  
  bufpos=0;
  tmp="";
  // return argum;  
}

void readCommand(char c){
  //   Serial.print(':');Serial.print(c);
  if ( client && client.connected()) telnetserver.print(c);
  if (c == '\n') {
    parseLine();
    memset(combuf, 0, 100);
  }
  else {
    combuf[bufpos++]=c;
  }
}


void parseLine(){
  parseCmdLine();
 // Serial.println(arguments->argv[0]);
  tmp = arguments.argv[0];
  if ( tmp == "ipx" ){
 //   Serial.println("IPX!!!");
    int a[3]={ 
      -1, -1, -1    };
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
 //   Serial.print("$");
//    Serial.println(arguments.argc,DEC);
    if (arguments.argc < 2) return;
    int i = atoi(arguments.argv[1]);
    ipxConfig[i].enabled=atoi(arguments.argv[2]);
//    Serial.print(arguments.argv[1]);
//    Serial.print(arguments.argv[2]);
    if (arguments.argc == 3) {
      byte tmpIP[4];
      strIp2byteVect(arguments.argv[3],tmpIP);
      if (tmpIP) {
        //Serial.print("Registering new poller"); 
        //ipxPolling[i].interval= atoi(arguments->argv[2]);
        memcpy(ipxConfig[i].ip, tmpIP, 4);     
        curPoll=i;
        //Serial.println("DONE!");
      }
    }
  }
  else if (tmp == "reboot") reboot();
  else if (tmp == "show") serialConfig();
  else if (tmp == "save") saveConfig();
  else if (tmp == "free") arduinoStatus();
  else if (tmp == "restorefactory") EEPROM.clear();
  else if (tmp == "set") {
     if (arguments.argc == 2)
      setConfig(arguments.argv[1], arguments.argv[2]); 
     else showConfig();
  }
 
  for (int i=0; i<=arguments.argc; i++)
    free(arguments.argv[i]);
 // free(arguments);  //  Serial.print('>');
  tmp="";
} 

void reboot() {
/*  wdt_disable();  
  wdt_enable(WDTO_15MS);
  while (1) {}
  */
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
