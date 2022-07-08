.equ TCR,		0x72000
.equ TLR,		0x72001
.equ TCount,		0x72002
.equ TIA,		0x72003
.equ Switches,		0x73000
.equ SSD_LL,		0x73002
.equ SSD_LR,		0x73003
.equ SSD_UR,		0x73007
.equ SSD_UL,		0x73006
.equ P_control,	0x73004
.equ LEDs,		0x7300A
.equ     pcb_link, 0      
.equ     pcb_reg1, 1      
.equ     pcb_reg2, 2      
.equ     pcb_reg3, 3      
.equ     pcb_reg4, 4
.equ     pcb_reg5, 5
.equ     pcb_reg6, 6
.equ     pcb_reg7, 7
.equ     pcb_reg8, 8
.equ     pcb_reg9, 9
.equ     pcb_reg10, 10
.equ     pcb_reg11, 11
.equ     pcb_reg12, 12
.equ     pcb_reg13, 13
.equ     pcb_sp, 14
.equ     pcb_ra, 15      
.equ     pcb_ear, 16      
.equ     pcb_cctrl, 17
.equ     pcb_timeslice, 18
.equ     pcb_exitflag, 19
.global main
.text
remove_serial:#these are all return address of specific pcbs
	la	$13, serial_pcb	#if a specific return address is used it will branch here
	sw	$0, pcb_exitflag($13)	#and remove that from the list of active pcbs
	j	wait_for_timer
remove_parallel:
	la	$13, parallel_pcb
	sw	$0, pcb_exitflag($13)
	j	wait_for_timer
remove_game:
	la	$13, gameSelect_pcb
	sw	$0, pcb_exitflag($13)
	j	wait_for_timer
main:
		
	movsg	$2, $cctrl		#take the current value of the cpu register#disable all interrupts 0000 0000 0000 1111
	addi	$2, $0, 0x4d
	movgs	$cctrl, $2		#enable timer and global interrupts (IRQ2 and IE) 1000 0010#now use our new generic handler		
	movsg	$2, $evec		#get the address of defaulthandler
	sw	$2, old_vector($0)	#back it up in memory
	la	$2, our_handler	#get the address of our generic handler
	movgs	$evec, $2		#now use our new generic handler					
	sw	$0, TIA($0)		#clear old interrupts
	addui	$2, $0, 24		#set value/duration to be counter, 2400Hz =1s
	sw	$2, TLR($0)
	addui	$2, $0, 0x03		#enable timer interup ant auto-reload moe 000 0011
	sw	$2, TCR($0)
	j	setup
		
setup:	   				 					
	addi	$5, $0, 0x4d 		# Unmask IRQ2,KU=1,OKU=1,IE=0,OIE=1 
					# Setup the pcb for process 1 
	la	$1, serial_pcb					# Setup the link field 
	la	$2, parallel_pcb 
	sw	$2, pcb_link($1) 					
	la	$2, process_serial_stack # Setup the stack pointer 
	sw	$2, pcb_sp($1) 	
	la	$2, remove_serial
	sw	$2,pcb_ra($1)
	sw	$5, pcb_cctrl($1)					
	la	$2, serial_main 	# Setup the $ear process1_pcbe
	sw	$2, pcb_ear($1)
	addi	$2, $0, 0x1
	sw	$2, pcb_exitflag($1)
	sw	$2, pcb_timeslice($1) 
		####################basically setting up all the pcbs, so that they work and link 1 to 2, 2 to 3, 3 to 1, as well as their unique return addresses
	la	$1, parallel_pcb	
	la	$2, gameSelect_pcb
	sw	$2, pcb_link($1) 	
	la	$2, process_parallel_stack #changed this from stack serial to parallel
	sw	$2, pcb_sp($1) 
	la	$2, remove_parallel
	sw	$2,pcb_ra($1)	
	la	$2, parallel_main 
	sw	$2, pcb_ear($1) 
	addi	$2, $0, 0x1
	sw	$2, pcb_exitflag($1)
	addi	$2, $0, 0x1
	sw	$2, pcb_timeslice($1) 					
	sw	$5, pcb_cctrl($1)  		# Setup the $cctrl field
	 					# Setup interrupts	      			
					
	la	$1, gameSelect_pcb	
	la	$2, serial_pcb
	sw	$2, pcb_link($1) 	
	la	$2, process_gameSelect_stack #changed this from stack serial to parallel
	sw	$2, pcb_sp($1)
	la	$2, remove_game
	sw	$2,pcb_ra($1)	
	la	$2, gameSelect_main 
	sw	$2, pcb_ear($1) 	
	addi	$2, $0, 0x1
	sw	$2, pcb_exitflag($1)
	addi	$2, $0, 0x4
	sw	$2, pcb_timeslice($1) 				
	sw	$5, pcb_cctrl($1)				
		
		
	la	$1, idle_pcb	
	la	$2, idle_pcb
	sw	$2, pcb_link($1) 	
	la	$2, process_idle_stack #changed this from stack serial to parallel
	sw	$2, pcb_sp($1) 
	#la	$2, remove_parallel
	#sw	$2,pcb_ra($1)	
	la	$2, idle_main 
	sw	$2, pcb_ear($1) 
	addi	$2, $0, 0x1
	sw	$2, pcb_exitflag($1)
	addi	$2, $0, 0x2
	sw	$2, pcb_timeslice($1) 					
	sw	$5, pcb_cctrl($1) 
					
										
	la	$1, serial_pcb    
	sw	$1, current_process($0)	
	addi	$1, $0, 1
	sw	$1, t_slice_temp($0)
	j	load_context	
		
our_handler:
		
	movsg	$13, $estat		#the cause of the interrupts
	andi	$13, $13, 0xFFB0		#check if the interrupt is because of programmabl timer
	beqz	$13, handler_timer	#no other interrupt; the timer vaused ot
	lw	$13, old_vector($0) 	#restore the old_vector as the handler
	jr	$13				#unfortunately, after handling the other interrupt it wil stop counting
		
handler_timer:
		
	sw	$0, TIA($0)			#acknowledg the interrupt
	lw	$13, counter($0)		#get the counter from memory
	addui	$13, $13, 1		#increment counter
	sw	$13, counter($0)		#put bakc in memory
	lw	$13, t_slice_temp($0)
	subi	$13, $13, 1
	sw	$13, t_slice_temp($0)
	beqz	$13, dispatcher
	rfe
			
dispatcher:      
	j save_context
save_context:     
							
	lw	$13, current_process($0)# Save the registers
	sw	$1, pcb_reg1($13)     
	sw	$2, pcb_reg2($13)
	sw	$3, pcb_reg3($13)  
	sw	$4, pcb_reg4($13)  
	sw	$5, pcb_reg5($13)  
	sw	$6, pcb_reg6($13)  
	sw	$7, pcb_reg7($13)  
	sw	$8, pcb_reg8($13)  
	sw	$9, pcb_reg9($13)  
	sw	$10, pcb_reg10($13)  
	sw	$11, pcb_reg11($13)  
	sw	$12, pcb_reg12($13)
	sw	$sp, pcb_sp($13) 	
	sw	$ra, pcb_ra($13)	    			   
	movsg	$1, $ers      				     
	sw	$1, pcb_reg13($13)      
	movsg	$1, $ear     
	sw	$1, pcb_ear($13)     
	movsg	$1, $cctrl    
	sw	$1, pcb_cctrl($13) 
	j	scheduler
		
scheduler: 
			
	lw	$13, idle_counter($0)
	beqz	$13, go_idle 		
	lw	$13, current_process($0)	# Get current process  
	lw	$13, pcb_link($13)
	lw	$13, pcb_exitflag($13)
	bnez	$13, active
	lw	$13, current_process($0)
	lw	$13, pcb_link($13)		# Get next process from pcb_link field     
	sw	$13, current_process($0)
	lw	$13, idle_counter($0)
	subi	$13, $13, 1
	sw	$13, idle_counter($0)
	j	scheduler
active:
	lw	$13, current_process($0)
	lw	$13, pcb_link($13)		# Get next process from pcb_link field     
	sw	$13, current_process($0)	# Set next process as current process     	
	lw	$13, current_process($0) 	#see what current process is
	lw	$13, pcb_timeslice($13) 
	sw	$13, t_slice_temp($0)
	addi	$13, $0, 3
	sw	$13, idle_counter($0) 
	j	load_context
		
go_idle:
	la	$13, idle_pcb
	sw	$13, current_process($0)	#make the idle pcb the current pcb
	lw	$13, pcb_timeslice($13) 
	sw	$13, t_slice_temp($0)	
	j	load_context
load_context:
		
	lw     $13, current_process($0)   
	lw     $1, pcb_reg13($13)     
	movgs  $ers, $1         
	lw     $1, pcb_ear($13)    
	movgs  $ear, $1     
	lw     $1, pcb_cctrl($13)   
	movgs  $cctrl, $1    
	lw $sp, pcb_sp($13) 	
	lw $ra, pcb_ra($13) 	  
	lw	$1, pcb_reg1($13)   
	lw	$2, pcb_reg2($13)
	lw	$3, pcb_reg3($13)  
	lw	$4, pcb_reg4($13)  
	lw	$5, pcb_reg5($13)  
	lw	$6, pcb_reg6($13)  
	lw	$7, pcb_reg7($13)  
	lw	$8, pcb_reg8($13)  
	lw	$9, pcb_reg9($13)  
	lw	$10, pcb_reg10($13)  
	lw	$11, pcb_reg11($13)     
	lw	$12, pcb_reg12($13) 
	rfe  
		
wait_for_timer:
	j	wait_for_timer	#this is an infinite loop that exhausts the timer
idle_main:
	addi	$4, $0, 14	#Basically displys idle
	sw	$4,SSD_LR($0)
	addi	$4, $0, 1
	sw	$4,SSD_LL($0)
	addi	$4, $0, 13
	sw	$4,SSD_UR($0)
	addi	$4, $0, 1
	sw	$4,SSD_UL($0)
	j	idle_main
.bss
old_vector:
	.word
serial_pcb:      
	.space   20
parallel_pcb:      
	.space   20	
gameSelect_pcb:     
	.space   20	
idle_pcb:
	.space	 20
current_process:
	.word	
# Stack for process 1 
    .space  200
    process_serial_stack:   
    .space 200
    process_parallel_stack:   
    .space 200
    process_gameSelect_stack:
      .space 200
    process_idle_stack:
.data
t_slice_temp: 
.word 0
idle_counter:
.word 3
