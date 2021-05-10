# IoT_TinyOSCooja
 **Third Homework of Internet Of Things**

 ### Authors \- ***Group 16*** :
- [Zaccaria Eliseo Carrettoni](https://github.com/IronZack95)

## TinyOS File:
> Homework3.h<br>
> Homework3AppC.nc<br>
> Homework3C.nc<br>

### WORKFLOW:
### *info:*
> open with Cooja and use with sky mote

## REPORT:
_Homework3.h Header files contains the structure of BROADCAST message,
composed by SenderID and conunter.
I created only one OS for all the 3 motes, the separation of the different behaviours
is driven by TOS_NODE_ID, with Switch Case statement.
In the Homework3C.nc is instantiated a local counter which is incremented every
time the timer fires, and for syncronization issues it is overrided by new
the incoming message's counter. I used "printf" to Serial function to print out Debugging messages._
