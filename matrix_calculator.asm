.glob main
.data
greeting: 	.asciiz "It's a matrix calculator!\n"
file_path:	.asciiz "/home/adam/Desktop/MIPS/code/data.txt"
error_message:	.asciiz "Error: opening file\nCheck file path!\n"
endl:		.asciiz "\n"
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
	la $a1, buff		#$10 = buff adress
	li $a2, 1024		#max number of char to read
	syscall
	
	move $s1, $v0		#storing number of char read
	li $v0,1		#printing number of char read
	move $a0, $s1
	syscall	
	
	li $v0,4		#printing endl
	la $a0, endl
	syscall	
	
	move $s6,$zero 		#number of bytes read from file stored in $s6
	
	jal get_m_n
	move $s2,$s7		#m1 - first matrix
	jal get_m_n
	move $s3,$s7		#n1 - first matrix
	
	#------------------------
	#la $t0,buff-redundant	#testing buffor output
	#lb $t1, buff
	#subi $t1,$t1,'0'
	li $v0,1
	move $a0, $s2
	syscall
	li $v0,4		#printing endl
	la $a0, endl
	syscall	
	li $v0,1
	move $a0, $s3
	syscall
	#------------------
	
	

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

	
#---------------------------------------------------------
#function to get matrx size
#$t0 holds result during counting and later on moves it to $s2 
get_m_n:

	la $t9, buff		#load buf address
	add $t9,$t9,$s6
	addiu $s6,$s6,1
				#first char
				
	lbu $t0, ($t9)		#load first char
	subi $t0,$t0,'0'	#convert to int
	
	#move $t8,$zero		
new_char:
	addi $s6,$s6,1	
	#addiu $t8,$t8,1		#loop counter
	#mulo $t7,$t7, $t8	#
	addiu $t9,$t9,1		#next bait in buf
	#lb $t1, 4(buff)
	lbu $t1,($t9)
	beqz $t1,end_int	#check if there are more to baits to read
	beq $t1,'\n',end_int
	beq $t1,' ',end_int
	subi $t1,$t1,'0'
	mulo $t0,$t0,10
	add $t0,$t0,$t1
	j new_char
end_int:	
	move $s7, $t0
	move $t0,$zero
	move $t1,$zero
	jr $ra
		
#---------------------------------------------------------
#function: int str_to_int(buf_adress, dynamic_memory_adress)
#return value is stored in 
#
str_to_int:
	

	
#	li $v0,1		#printing file descriptor
#	move $a0, $t0
#	syscall