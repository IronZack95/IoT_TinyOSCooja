 #include "Timer.h"
#include "Homework3.h"
#include "printf.h"
#include <stdio.h>
#include <stdint.h>

module Homework3C @safe() {
  uses {
    interface Leds;
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as MilliTimer;
    interface SplitControl as AMControl;
    interface Packet;
  }
}

implementation {

  message_t packet;

  bool locked;
  uint16_t counter = 0;
  bool led0 = FALSE;				// stato dei led
  bool led1 = FALSE;
  bool led2 = FALSE;

  event void Boot.booted() {
    call AMControl.start();
    led0 = FALSE; 
    call Leds.led0Off();
    led1 = FALSE; 
    call Leds.led1Off();
    led2 = FALSE; 
    call Leds.led2Off();
    printf("Hi I am Ready!!\n");
    printfflush();
  	printf("led: %d%d%d c: %d\n",led2,led1,led0,counter);
  	printfflush();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
    switch(TOS_NODE_ID){
    	case 1: call MilliTimer.startPeriodic(1000); break;
    	case 2: call MilliTimer.startPeriodic(333); break;
    	case 3: call MilliTimer.startPeriodic(200); break;
    	default: 
    	}
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
  
  event void MilliTimer.fired() {
    counter++;
    
    if (locked) {																						// controllo se sono bloccato
      return;
    }
    else {
      radio_count_msg_t* rcm = (radio_count_msg_t*)call Packet.getPayload(&packet, sizeof(radio_count_msg_t));
      if (rcm == NULL) {
		return;
      }

  	  rcm->counter = counter;																			// aggiungo informazioni al pacchetto da mandare
      rcm->senderID = TOS_NODE_ID;
      
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {
		locked = TRUE;
      }
    }
  }

  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    counter++;																							// incremento il counter ogni volta che ricevo un messaggio
    //dbg("Homework3C", "Received packet of length %hhu.\n", len);		// debugging
    
    if (len != sizeof(radio_count_msg_t)) {return bufPtr;}												// controllo se il messaggio ricevuto è giusto
    else {
		  radio_count_msg_t* rcm = (radio_count_msg_t*)payload;											// controllo il payload
		  
		  if (rcm->counter >= 10) {
					//spegimento totale
					led0 = FALSE; 
					call Leds.led0Off();
					led1 = FALSE; 
					call Leds.led1Off();
					led2 = FALSE; 
					call Leds.led2Off();
					counter = 0;
					printf("OVER!!\n");
					printfflush();
		  }
		  else {
	      		switch(rcm->senderID){
					case 1: 
						if(led0){call Leds.led0Off();}else{{call Leds.led0On();}}
						led0 = !led0;
						break;
					case 2: 
						if(led1){call Leds.led1Off();}else{{call Leds.led1On();}}
						led1 = !led1;
						break;
					case 3: 
						if(led2){call Leds.led2Off();}else{{call Leds.led2On();}}
						led2 = !led2;
						break;
					default:
				}
				counter = rcm->counter;			// sincronizzo all'ultimo messaggio ricevuto
		  }
		  printf("led: %d%d%d c: %d\n",led2,led1,led0,counter);
		  printfflush();
		  return bufPtr;
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

}
