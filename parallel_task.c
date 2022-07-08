#include "wramp.h"

int s_buttons = 0;
int mask_p=0;
int f4=0;//first 4
int s4=0;//second four
int t4=0;//third four
int l4=0;//last four
int view_Switches=0;
	
void parallel_main(){
while(1){

	view_Switches=WrampParallel->Switches;//read in switches and base display in hex
	f4=(view_Switches& 0xf);
	
	view_Switches=view_Switches >>4;
	s4=(view_Switches& 0xf);
	
	view_Switches=view_Switches >>4;
	t4=(view_Switches& 0xf);
	
	view_Switches=view_Switches >>4;
	l4=(view_Switches& 0xf);
	
	WrampParallel->LowerRightSSD = f4;
	WrampParallel->LowerLeftSSD = s4;
	WrampParallel->UpperRightSSD = t4;
	WrampParallel->UpperLeftSSD = l4;
	//break;
	if((WrampParallel->Buttons & 0x2)==2){//masks the button register to isolate the one in the scond place so that when you compare it later it will be an integer2
	//base 16
		while(1){
		view_Switches=WrampParallel->Switches;//rads in switches
		f4=(view_Switches& 0xf);
		
		view_Switches=view_Switches >>4;//translate to hex
		s4=(view_Switches& 0xf);
		
		view_Switches=view_Switches >>4;
		t4=(view_Switches& 0xf);
		
		view_Switches=view_Switches >>4;
		l4=(view_Switches& 0xf);
		
		WrampParallel->LowerRightSSD = f4;//disp
		WrampParallel->LowerLeftSSD = s4;
		WrampParallel->UpperRightSSD = t4;
		WrampParallel->UpperLeftSSD = l4;
			if((WrampParallel->Buttons & 0x1)==1){//these are seeing if other buttons are pressed
				WrampParallel->Buttons =1;//resetting so that the if reads in correctly
				break;
				}
			if(WrampParallel->Buttons==4){
				WrampParallel->Buttons =4;
				break;
				}
			//break;
			}
	}
	else if((WrampParallel->Buttons & 0x1)==1){
	//base 10
		while(1){
		view_Switches=WrampParallel->Switches;
		f4=view_Switches%10;
		view_Switches=view_Switches/10;
		s4= view_Switches%10;
		view_Switches=view_Switches/10;
		t4=	view_Switches%10;
		view_Switches=view_Switches/10;
		l4 =view_Switches%10;

		WrampParallel->LowerRightSSD = f4;
		WrampParallel->LowerLeftSSD = s4;
		WrampParallel->UpperRightSSD = t4;
		WrampParallel->UpperLeftSSD = l4;
			if((WrampParallel->Buttons & 0x2)==2){//these are seeing if other buttons are pressed
			WrampParallel->Buttons =2;
			break;}
			if(WrampParallel->Buttons==4){
			WrampParallel->Buttons =4;
			break;
			}
		}
		//break;
	}
	else if(WrampParallel->Buttons==4){
	WrampParallel->LowerRightSSD = '0';
	WrampParallel->LowerLeftSSD = '0';
	WrampParallel->UpperRightSSD = '0';
	WrampParallel->UpperLeftSSD = '0';//dont need to check buttons after this as the program will be finished
	return;
	//break;
	}
	
	
}
//Smain();


}
