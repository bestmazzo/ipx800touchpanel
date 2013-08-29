void HTTPget(IPAddress& address, String page, int port, int mode){
  EthernetClient machine;
  // Serial.println(address);

  if (machine.connect(address, port)){
    //  Serial.println(machine.status(),DEC);
    String req = "GET /" + page + " HTTP/1.0";
    machine.println(req);
    machine.println();
    if (mode==0){      
      delay(IPX800TSconf.httpRXwait);
      while (machine.available()) 
         readXMLchar(machine.read());    
    }
    
    machine.flush();
    machine.stop(); 
    //delay(1000);
  }
  //else   Serial.print("E:ConFail");
}

/*
 * Ritorna un vettore di 4 byte ottenuto dalla stringa str
 * rappresentante un indirizzo ip.
 * Ritorna null nel caso in cui str non rappresenta un indirizzo ip.
 */
int strIp2byteVect(String str, byte * ipVect){
  String tmpStr;
  int bytesCount,			 //contatore per il num di byte
	i;				    //contatore per il ciclo sulla stringa
//  byte *ipVect = (byte *) malloc(4);
  
  i = 0;
  for (bytesCount = 0; bytesCount < 4; bytesCount++){     //Ciclo sui byte
    for ( ; (str.charAt(i) != '.') && (str.charAt(i) != '\0'); i++)  //Ciclo sulla stringa
	tmpStr += str.charAt(i);
    ipVect[bytesCount] = tmpStr.toInt();
    tmpStr = "";
    ++i;
  }

  if (bytesCount != 4){
    return 0;
  }
  return 1;
}

#define ASCII_HEX_START_CHAR  65		  //Index of ascii char 'A'

/*
 * Ritorna la conversione decimale del codice
 * esadecimale contenuto in str.
 * Nel caso in cui str non e' un codice esadecimale ritorna -1.
 *
 * TODO: verifica se e' possibile rappresentare
 *	 il codice esadecimale str con un int.
 */
int hexString2dec(String str){
  int strLen = str.length(),    //numero di caratteri esadecimali
	tmpNumber;		    //intero temporaneo per l'i-esimo carattere
  double result = 0;		//risultato complessivo della conversione
  char tmpChar;		     //carattere temporaneo per l'i-esimo elemento di str
  
  str.toUpperCase();	//converte i caratteri in maiuscoli per il codice ascii
  
  for (int i = 0; i < strLen; ++i){  //ciclo sui caratteri di str
    tmpChar = str.charAt(i);
    //conversione dell'i-esimo carattere o numero di str in intero
    if (isDigit(tmpChar)) //numero
	tmpNumber = atoi(&tmpChar);
    else
	if (isHexadecimalDigit(tmpChar))  //carattere
	  tmpNumber = tmpChar - ASCII_HEX_START_CHAR + 10;
	else
	  return -1;    //se il carattere non e' riconosciuto come esadecimale ritorna -1
    result += pow(16, strLen - i - 1) * tmpNumber;  //aggiornamento risultato
  }

  //per la conversione in int del risultato senza perdita di precisione
  if ((result*10-((int)result*10)) >= 5)    
    return result+1;
  else
    return result;
}

/*
 * Ritorna un vettore di 6 byte ottenuto dalla stringa str
 * rappresentante un mac address.
 * Ritorna null nel caso in cui str non rappresenta un mac address.
 */
int strMac2byteVect(String str, byte *macVect){
  //byte *macVect = (byte *) malloc(6);
  str.replace(":", "");    //elimina i separatori
  
  for (int i = 0; i < 12; i += 2){   //Ciclo sulle coppie di caratteri
    macVect[i/2] = hexString2dec(str.substring(i, i+2));  //Inizializza l'i-esimo byte del mac
    if (macVect[i/2] == -1){
	//free(macVect);
	return 0;
    }
  }
  return 1;  
}

String ipStr;
String & iptostring(IPAddress &ip){
  ipStr="";
  for (int i = 0; i < 4; ++i) {
    ipStr += String(ip[i]);
    if (i < 3)
       ipStr += '.';
  }
 return ipStr;
  
}

void mergeip(int *src, int *dst){
  for (int i=0;i<4;i++)
    dst[i]=src[i];
}

