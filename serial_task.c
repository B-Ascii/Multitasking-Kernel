#include "wramp.h"

int counter=000000;

int q=0;
int m2_second='0';
int m1_second='0';//initialising values
int lr_second='0';
int ll_second='0';
int ur_second='0';
int ul_second='0';
int view1_counter='0';
int minTOT='0';
int secTOT='0';
int min1='0';
int min2='0';
int initial=0;
void PrintSp2(int a){
 //WrampParallel->LowerRightSSD = a;
while(!(WrampSp2->Stat & 2));
WrampSp2->Tx = a;
}
void serial_main(){
//PrintSp2(counter);
//while(!(WrampSp2->Stat & 1));//while the status is not 1 in the register get stuck here
while(1)
{
//counter++;
  if(initial==0){
     
        view1_counter=counter;//while nothing has been pressed, pretend 1 has been pressed
        view1_counter= view1_counter/100;
        minTOT=view1_counter/60;//this gets minutes
        secTOT=view1_counter%60;//this gets seconds
        min2=minTOT%10+'0';
        min1=(minTOT/10)%10+'0';
        lr_second=secTOT%10+'0';
        ll_second=(secTOT/10)%10+'0';
        PrintSp2('\r');
        PrintSp2(min1);
        PrintSp2(min2);
        PrintSp2(':');
        PrintSp2(ll_second);
        PrintSp2(lr_second);
        PrintSp2(' ');
        PrintSp2(' ');
    }
   if((WrampSp2 ->Rx)=='1'){
    //"\rmm:ss”
    view1_counter=counter;
    view1_counter= view1_counter/100;
    minTOT=view1_counter/60;//this gets minutes
    secTOT=view1_counter%60;//this gets seconds
    min2=minTOT%10+'0';
    min1=(minTOT/10)%10+'0';
    lr_second=secTOT%10+'0';
    ll_second=(secTOT/10)%10+'0';
    PrintSp2('\r');
        PrintSp2(min1);
        PrintSp2(min2);
        PrintSp2(':');
        PrintSp2(ll_second);
        PrintSp2(lr_second);
    PrintSp2(' ');
    PrintSp2(' ');
    initial=1;
    }
    else if((WrampSp2 ->Rx)=='2'){
        view1_counter=counter;
        m2_second=view1_counter%10 +'0';//this isolates digits
        view1_counter=view1_counter/10;
        m1_second=view1_counter%10 +'0';
        view1_counter=view1_counter/10;
        lr_second=view1_counter%10 +'0';
        view1_counter=view1_counter/10;
        ll_second=view1_counter%10 +'0';
        view1_counter=view1_counter/10;
        ur_second=view1_counter%10 +'0';
        view1_counter=view1_counter/10;
        ul_second=view1_counter%10 +'0';
        PrintSp2('\r');
        PrintSp2(ul_second);
        PrintSp2(ur_second);
        PrintSp2(ll_second);
        PrintSp2(lr_second);
        PrintSp2('.');
        PrintSp2(m1_second);
        PrintSp2(m2_second);
        initial=1;
    }
    else if((WrampSp2 ->Rx)=='3'){
    view1_counter=counter;
        m2_second=view1_counter%10 +'0';
        view1_counter=view1_counter/10;
        m1_second=view1_counter%10 +'0';
        view1_counter=view1_counter/10;
        lr_second=view1_counter%10 +'0';
        view1_counter=view1_counter/10;
        ll_second=view1_counter%10 +'0';
        view1_counter=view1_counter/10;
        ur_second=view1_counter%10 +'0';
        view1_counter=view1_counter/10;
        ul_second=view1_counter%10 +'0';
        PrintSp2('\r');
        PrintSp2(ul_second);
        PrintSp2(ur_second);
        PrintSp2(ll_second);
        PrintSp2(lr_second);
        PrintSp2(m1_second);
        PrintSp2(m2_second);
        PrintSp2(' ');
        initial=1;
    }
    else if((WrampSp2 ->Rx)=='q'){return;}//return
    

}
    
}
