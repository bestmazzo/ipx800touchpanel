
void readXMLchar(char c){
 if (c == '\n') {
    parseXMLline();
    memset(xmlLine, 0, XMLLINELEN);
    xmlbufpos = 0;
  }
  else {
    xmlLine[xmlbufpos++]=c;
  } 
}

void parseXMLline(){
 String xmlstring = xmlLine;
 String tag="";
 char * data;
 int i,j;
 // 0 = < 
 // 1 ~ i = tag
 if (xmlstring[1] != '/' ) {
   i = xmlstring.indexOf('>');
//   Serial.print("i:"); Serial.print(i,DEC);
   if (i != -1) {
     for ( int k=1; k<i; k++)
       tag += xmlstring[k];
   
     // i ~ j = data
     j = xmlstring.indexOf('<',i+1);
//     Serial.print(" j:"); Serial.print(j,DEC);
     if (j != -1) {
       data= (char *) malloc(j-i+1);
       for ( int k=i+1; k<j; k++)
         data[k-i-1] = xmlstring[k];
       data[j-i]='\0';
         
       parseXMLcommand(tag, data);
       free(data);
     }
   }
 }
}

void parseXMLcommand( String tagstr,  char *data){    
   //Serial.print(tagstr);Serial.print("->");Serial.println(data);
    if ( tagstr.startsWith("led"))  ipx.l[tagstr[3]-48]=atoi(data);
    else if ( tagstr.startsWith("an")) ipx.a[tagstr[2]-49]=atoi(data);      
    else if ( tagstr.startsWith("btn")) ipx.d[tagstr[3]-48]= (data[0] == 'd');      
    else if ( tagstr.startsWith("time0")) memcpy(timeStr,data,8);      
 
}


