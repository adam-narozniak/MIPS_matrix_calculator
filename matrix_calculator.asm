.glob main
.data
greeting: 	.asciiz "It's a matrix calculator!\n"
file_path:	.asciiz "/home/adam/Desktop/MIPS/code/data.txt"
error_message:	.asciiz "Error: opening file\nCheck file path!\n"
if_testing:	.asciiz "Loop testing\n"
plus:		.asciiz "+\n"
minus:		.asciiz "-\n"
val1:		.word 2
val2:		.word 1
buff:		.space 1024
.text
main:
	li $v0,4		#printing greetings
	la $a0,greeting
	syscall
open_f:	
	li $v0,13		#open file
	la $a0,file_path
	li $a1,0		#read-only flag
	syscall
	
	move $s0, $v0		#file descriptor to $s0
	blt $s0,$zero,end_err	#branch if file not opended properly
	
read_f:
	li $v0,14
	move $a0, $s0		#$a0 = file descriptor
	la $a1, buff		#$a0 = buff adress
	li $a2, 1024		#max number of char to read
	syscall
	
	move $s1, $v0		#storing number of char read
	li $v0,1		#printing number of char read
	move $a0, $s1
	syscall	
	
	la $t0,buff		#testing buffor output
	lb $t1, ($t0)
	subi $t1,$t1,0x30
	li $v0,1
	move $a0, $t1
	syscall
	

close_f:
	li $v0,16		#closing file
	move $a0, $s0		#$a0 = file descriptor
	syscall
	j end
end_err:
	li $v0,4		#printing error message
	la $a0,error_message
	syscall
		
end:	li $v0,10		#exit
	syscall
	
#	li $v0,1		#printing file descriptor
#	move $a0, $t0
#	syscall