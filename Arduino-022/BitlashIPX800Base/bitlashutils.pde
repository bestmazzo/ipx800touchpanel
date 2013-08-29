
#include "bitlash.h"


void serialHandler(byte b) {
	Serial.print(b, BYTE);
	if (client && client.connected()) client.print((char) b);
}


void blSetup(){
          
        initBitlash(57600);    
        
//       addBitlashFunction("cfg", &configuration);      
        addBitlashFunction("ipx", &ipxCmd);
    
        setOutputHandler(&serialHandler);
        
//        if (getValue("config") >= 0) doCommand("config"); 
//         else {
//             doCommand("function config{a=192;b=168;c=2;d=14;e=255;f=255;g=255;h=0;i=192;j=168;k=2;l=254;m=192;n=43;o=244;p=18;t=2;};");
//             Serial.println("Init done, rebooting!");
//             doCommand("boot");
//         }
//        
//        for (int i=0; i<4; i++){
//          ip[i]= getVar(i); // address = a,b,c,d
//          netmask[i]=getVar(i+4); // netmask = e,f,g,h
//          gateway[i]=getVar(i+8); // gateway = i,j,k,l
//          ntpip[i]=getVar(i+12); // ntp server = m,n,o,p          
//        }
//        TimeZoneOffset = getVar('t'-'a');
        
        Ethernet.begin(mac, ip, gateway, netmask);
        telnetserver.begin();
        Udp.begin(9999);
}

void blLoop(){
  	
	client = telnetserver.available();
	if (client) {
		while (client.connected()) {
			if (client.available()) {
				char c = (char) client.read();
				if (c != '\n') doCharacter(c);	// prevent double prompts
			}
			else runBitlash();
		}
	}
	runBitlash();
}

void ifdoCommand(char *command){
 if (getValue(command) >= 0) doCommand(command);
}



numvar configuration(){
   String tmp;
//   switch (getarg(0) ){
//    case 5:   
//          for (int i=0; i<4; i++)
//            remoteip[i]=getarg(i+2);
//          
//          switch (getarg(1)){
//            case 'a': mergeip(remoteip, ip); break; 
//            case 'n': mergeip(remoteip, netmask); break;
//            case 'g': mergeip(remoteip, gateway); break;
// next functions consumes too much space into sketch..

//          }
//           break;
      if (getarg(0) == 1){
          switch (getarg(1)){
            case 'a': tmp=iptostring(ip); break;
            case 'n': tmp=iptostring(netmask); break;
            case 'g': tmp=iptostring(gateway); break;
            case 't': tmp=iptostring(ntpip); break;
            case 'r': tmp=iptostring(remoteip);break;
          case 'h': tmp = ct.Hour; break;
          case 'm': tmp = ct.Minute; break;
          case 's': tmp = ct.Second; break;
          case 'd': tmp = ct.Day; break;
          case 'M': tmp = ct.Month; break;
          case 'y': tmp = ct.Year; break;
          }
           Serial.println(tmp);
//      case 2:
//          switch (getarg(1)){
//            case 'o': TimeZoneOffset=getarg(2); onday(); break;
//          }
//          break;    
      }
 }


    
