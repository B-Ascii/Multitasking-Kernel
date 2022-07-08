				#define list of macros to make our code more legible
.equ TCR,		0x72000
.equ TLR,		0x72001
.equ TCount,		0x72002
.equ TIA,		0x72003
.equ Switches,		0x73000
.equ SSD_LL,		0x73002
.equ SSD_LR,		0x73003
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





.global main
.text
main:

	movsg $2, $cctrl		#take the current value of the cpu register
	andi $2, $2, 0x00f		#disable all interrupts 0000 0000 0000 1111
	ori $2, $2, 0x42		#enable timer and global interrupts (IRQ2 and IE) 1000 0010
	movgs $cctrl, $2		#now use our new generic handler	
	
					#setup a new exception/interrupt handler
	movsg $2, $evec		#get the address of defaulthandler
	sw $2, old_vector($0)		#back it up in memory
	la $2, our_handler		#get the address of our generic handler
	movgs	$evec, $2		#now use our new generic handler
	
					#setup timer
	sw $0, TIA($0)			#clear old interrupts
	addui $2, $0, 24		#set value/duration to be counter, 2400Hz =1s
	sw $2, TLR($0)
	addui $2, $0, 0x03		#enable timer interup ant auto-reload moe 000 0011
	sw $2, TCR($0)
	j setup
setup:	   
					# Setup processes   
					# Unmask IRQ2,KU=1,OKU=1,IE=0,OIE=1 
	addi  $5, $0, 0x4f 		#... 
					# Setup the pcb for process 1 
	la    $1, serial_pcb					# Setup the link field 
	la    $2, parallel_pcb 
	sw    $2, pcb_link($1) 					
	la    $2, process_serial_stack # Setup the stack pointer 
	sw    $2, pcb_sp($1) 	
	sw    $5, pcb_cctrl($1)					
	la    $2, serial_main # Setup the $ear fiprocess1_pcbeld 
	sw    $2, pcb_ear($1) 
	
	
	
	
	
	la    $1, parallel_pcb	
	la    $2, serial_pcb
	sw    $2, pcb_link($1) 	
	la    $2, process_parallel_stack #changed this from stack serial to parallel
	sw    $2, pcb_sp($1) 	
	la    $2, parallel_main 
	sw    $2, pcb_ear($1) 					
	sw    $5, pcb_cctrl($1)  	# Setup the $cctrl field
	 				# Setup interrupts	      
	 				# Start first process (via dispatcher)	 
					# Set first process as the current process  
	la    $1, serial_pcb    
       sw    $1, current_process($0)	
	addi $13, $0, 2
	sw $13, t_slice_serial($0)

j load_context	
#	j serial_main
	


our_handler:
	movsg $13, $estat		#the cause of the interrupts
	andi $13, $13, 0xFFB0		#check if the interrupt is because of programmabl timer
	beqz $13, handler_timer	#no other interrupt; the timer vaused ot
	lw $13, old_vector($0) 	#restore the old_vector as the handler
	jr $13				#unfortunately, after handling the other interrupt it wil stop counting
	
handler_timer:

	sw $0, TIA($0)			#acknowledg the interrupt
	lw $13, counter($0)		#get the counter from memory
	addui $13, $13, 1		#increment counter
	sw $13, counter($0)		#put bakc in memory
	lw $13, t_slice_serial($0)
	beqz $13, dispatcher
	subi $13, $13, 1
	sw $13, t_slice_serial($0)
	rfe	
	
dispatcher:      
					# Save context for current process  
	j save_context
save_context:     
					# Get the base address of the current PCB
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
					# $1 is saved now so we can use it     
	 				# Get the old value of $13    
	movsg  $1, $ers     
	 				# and save it to the pcb     
	sw     $1, pcb_reg13($13)      
	 				# Save $ear    addi $13, $0, 2
	sw $13, t_slice_serial($0)
	movsg  $1, $ear     
	sw     $1, pcb_ear($13)   
	 				# Save $cctrl     
	movsg  $1, $cctrl    
	sw     $1, pcb_cctrl($13) 
	j scheduler
	 
scheduler: 
	 
					# Select (schedule) the next process
	lw $13, current_process($0)	# Get current process    
	lw $13, pcb_link($13)		# Get next process from pcb_link field     
	sw $13, current_process($0)	# Set next process as current process     
					# Reset the timeslice counter to an appropriate value 
	
					#set the timeslice back to 2
	
	addi $13, $0, 2
	sw $13, t_slice_serial($0)	    
	# Load context for next process   
	j load_context
load_context:
	lw     $13, current_process($0)
	 				# Get PCB of current process     
					# Get the PCB value for $13 back into $ers     
	lw     $1, pcb_reg13($13)     
	movgs  $ers, $1     
	 				# Restore $ear     
	lw     $1, pcb_ear($13)    
	movgs  $ear, $1    
	 				# Restore $cctrl   
	lw     $1, pcb_cctrl($13)   
	movgs  $cctrl, $1    
	 				# Restore the other registers    
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
	 				# Return to the new process   
	rfe  
	# Continue with next process (rfe)
	
.bss
old_vector:
	.word

serial_pcb: 
     
	.space   18

parallel_pcb:
      
	.space   18
	
process3_pcb: 
    
	.space   18
	
current_process:

	.word
	
# Stack for process 1 

    .space  200
    process_serial_stack:
    
    .space 200
    process_parallel_stack:
.data
t_slice_serial: .word 2


