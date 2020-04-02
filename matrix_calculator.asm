.glob main
.data
greeting: 	.asciiz "It's a matrix calculator!\n"
file_path:	.asciiz "/home/adam/Desktop/MIPS/code/data.txt"
error_message:	.asciiz "Error: opening file\nCheck file path!\n"
endl:		.asciiz "\n"
if_testing:	.asciiz "Loop testing\n"
plus:		.asciiz "+\n"
minus:		.asciiz "-"
val1:		.word 2
val2:		.word 1
buf:		.space 1024
.text
#$s0 file descriptor
#$s1 m1
#$s2 n1
#$s3 m2
#$s4 n2
#$s5 current buff address
#$s6 address of alocated dynamically memory for (firstly begining,
#later on current)
#$s7 
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
	la $a1, buf		#$a1 = buff adress
	li $a2, 1024		#$a2 = max number of char to read(buff size)
	syscall
	
	move $t0, $v0		#storing number of char read
	li $v0,1		#printing number of char read
	move $a0, $t0
	syscall	
	
	jal print_endl
		
	
	la $s5,buf		#current buf address
	
	jal get_m_n
	move $s1,$s7		#m1 - first matrix
	jal get_m_n
	move $s2,$s7		#n1 - first matrix
	
	addi $sp,$sp,-8 	#space for two adresses dynamically allocated memory of 
	mul $t0,$s1,$s2		#n1*m1 number of elem in matrix
	addi $sp,$sp,-4		#space for n1*m1 of stack (argument of the fuction)
	sw $t0,($sp)		#store above
	addi $sp,$sp,-4
	la $t0, 12($sp)		#store address of space to write address of memory
	sw $t0,($sp)
	jal get_matrix
	
	
	
	#------------------------
	#la $t0,buff-redundant	#testing buffor output
	#lb $t1, buff
	#subi $t1,$t1,'0'
	li $v0,1		#printing m1 n1
	move $a0, $s1
	syscall
	jal print_endl
	li $v0,1
	move $a0, $s2
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

	#la $t9, buf		#load buf address
	#add $t9,$t9,$s6
	#addiu $s6,$s6,1
				#first char
				
	lbu $t0, ($s5)		#load first char
	addiu $s5,$s5,1
	subi $t0,$t0,'0'	#convert to int
	
	#move $t8,$zero		
new_char:
	#addi $s6,$s6,1	
	#addiu $t8,$t8,1		#loop counter
	#mulo $t7,$t7, $t8	#
	#addiu $t9,$t9,1		#next bait in buf
	#lb $t1, 4(buff)
	lbu $t1,($s5)
	addiu $s5,$s5,1
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
get_matrix:
	addiu $sp,$sp,-4		#taking care of frame pointer and return adress
	sw $ra,0($sp)
	addiu $sp,$sp,-4
	sw $fp,0($sp)
	move $fp,$sp
	#addi $sp,$sp,-4			#place for local current addres of allocated memory for matrix
	
	
	
	li $v0, 9			#allocating memory on heap
	lw $a0, 12($fp)			#loading m*n
	syscall
	sw $v0,8($fp)			#storing address of memory allocated for matrix
					#in adrress given as *address
#-----------------------------------------
#reading matrix	
whole_loop:		#loop to get all numbers,
			#whereas the lower ones are to get sigle number
			#$t9 as place for local current addres of allocated memory for matrix
			#$t8, loop counter
	lbu $t0, ($s5)			#load first char, $s5 current buff adress
	addiu $s5,$s5,1
	beq $t0,'-', negative		#negative number - >jump
	subi $t0,$t0,'0'	#convert to int
pos_loop:
	lbu $t1,($s5)
	addiu $s5,$s5,1
	beqz $t1,end_int_pos	#check if there are more to baits to read
	beq $t1,'\n',end_int_pos
	beq $t1,' ',end_int_pos
	subi $t1,$t1,'0'
	mulo $t0,$t0,10
	add $t0,$t0,$t1
	j pos_loop
end_int_pos:
	
	sw $t0,($t9)
	addiu $t9,$t9,1
	move $t0,$zero
	move $t1,$zero
	j whole_loop
	
	
negative:
	lbu $t0, ($s5)			#start reading digits
	addiu $s5,$s5,1
	subi $t0,$t0,'0'	#convert to int
neg_loop:	
	lbu $t1,($s5)
	addiu $s5,$s5,1
	beqz $t1,end_int_neg	#check if there are more to baits to read
	beq $t1,'\n',end_int_neg
	beq $t1,' ',end_int_neg
	subi $t1,$t1,'0'
	mulo $t0,$t0,10
	add $t0,$t0,$t1
	j neg_lop
end_int_neg:
	
	
	
	jr $ra
	

	
#	li $v0,1		#printing file descriptor
#	move $a0, $t0
#	syscall
#----------------------------------
print_endl:
	li $v0,4		#printing endl
	la $a0, endl
	syscall
	jr $ra