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

.global main
.text
main:

	movsg $2, $cctrl	#take the current value of the cpu register
	andi $2, $2, 0x00f	#disable all interrupts 0000 0000 0000 1111
	ori $2, $2, 0x42	#enable timer and global interrupts (IRQ2 and IE) 1000 0010
	movgs $cctrl, $2	#now use our new generic handler
	
	
	#setup a new exception/interrupt handler
	movsg $2, $evec	#get the address of defaulthandler
	sw $2, old_vector($0)	#back it up in memory
	la $2, our_handler	#get the address of our generic handler
	movgs	$evec, $2	#now use our new generic handler
	
	#setup timer
	sw $0, TIA($0)		#clear old interrupts
	addui $2, $0, 24	#set value/duration to be counter, 2400Hz =1s
	sw $2, TLR($0)
	addui $2, $0, 0x03	#enable timer interup ant auto-reload moe 000 0011
	sw $2, TCR($0)
	
	jal serial_main
	


our_handler:
	movsg $13, $estat	#the cause of the interrupts
	andi $13, $13, 0xFFB0	#check if the interrupt is because of programmabl timer
	beqz $13, handler_timer#no other interrupt; the timer vaused ot
	lw $13, old_vector($0) #restore the old_vector as the handler
	jr $13			#unfortunately, after handling the other interrupt it wil stop counting
	
handler_timer:
	sw $0, TIA($0)		#acknowledg the interrupt
	lw $13, counter($0)	#get the counter from memory
	addui $13, $13, 1	#increment counter
	sw $13, counter($0)	#put bakc in memory
	rfe	
	
.bss
old_vector:	.word
