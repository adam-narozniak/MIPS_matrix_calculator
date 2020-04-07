.data
greeting: 	.asciiz "It's a matrix calculator!\n"
file_path:	.asciiz "/home/adam/Desktop/MIPS/code/data.txt"
error_open:	.asciiz "Error: opening file\nCheck file path!\n"
error_format:	.asciiz "Error: wrong format of the data in the file\nOperation not specified\n"
error_sizes:	.asciiz "Error: not correct sizes of matrices to perform specified operation\nCheck first line of the file\n"
endl:		.asciiz "\n"
space:		.asciiz " "
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
#$s6 operation type: 
# 1 '+',  2 "-', 3 '*', 4 'det'
#$s7 
.globl main
main:
	li $v0,4		#printing greetings
	la $a0,greeting
	syscall
open_f:	
	li $v0,13		#open file
	la $a0,file_path
	li $a1,0		#read-only flag
	syscall
	
	move $s0, $v0			#file descriptor to $s0
	blt $s0,$zero,end_err_open	#branch if file not opended properly
	
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
		
	#getting type of operation to execute
	la $s5,buf		#current buf address
	jal get_operation_type
	
	move $fp,$sp
	#space for two local variables(in main) m1*n1 and m2*n2
	addiu $sp,$sp,-4		#space for two local variables(in main) m1*n1 and m2*n2
	addiu $sp,$sp,-8 	#space for two adresses of dynamically allocated memory for matrices - local(in main) variables
	
m1_n1:	#first matrix read
	jal get_m_n
	move $s1,$s7		#m1 - first matrix
	jal get_m_n
	move $s2,$s7		#n1 - first matrix
	
	
matrix1:	#this is each call routine
	mul $t0,$s1,$s2		#$t0= n1*m1 number of elem in matrix
	sw $t0,12($sp)		#storing m1*n1 in on stack as local variable in main							m1*n1
	addiu $sp,$sp,-4		#space for $t0 (argument of the fuction), which contains m*n
	sw $t0,($sp)		#store $t0
	# you should specify this each time 
	#la $t0, 8($sp)		#store address of space to write address of memory
	add $t0,$sp,8
	addiu $sp,$sp,-4
	sw $t0,($sp)
	jal get_matrix
	addiu $sp,$sp,8 	#deaclocating space for arg of function
	
m2_n2:	#second matrix read
	jal get_m_n
	move $s3,$s7		#m2 - second matrix
	jal get_m_n
	move $s4,$s7		#n2 - second matrix
matrix2:	#this is each call routine
	mul $t0,$s3,$s4		#$t0= n*m number of elem in matrix
	sw $t0,8($sp)		#storing m1*n1 in on stack as local variable in main							m2*n2
	addiu $sp,$sp,-4	#space for $t0 (argument of the fuction), which contains m*n
	sw $t0,($sp)		#store $t0
	# you should specify this each time 
	#la $t0, 4($sp)		#store address of space to write address of memory
	add $t0,$sp,4
	addiu $sp,$sp,-4
	sw $t0,($sp)
	jal get_matrix
	addiu $sp,$sp,8 	#deaclocating space for arg of function
	
	
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
	jal print_endl
	
	#------------------
	#fuction print_matrix(int* matrix_begin, int m, int n):
	#addiu $sp,$sp,-4
	
	
	
	
#CONVENTION HERE	
#here in loop for add sub
# $t0 loop counter 
#$t7 $8 respectively adddress of matrix1 and 2 


	lw $t7, 4($sp)
	lw $t8, ($sp)
#space for address of allocated memory for matrix -creating local variable in main for 
	addiu $sp,$sp,-4
	
	
	
	bne $s6,1, c2_cond		#if $s6 != 1 check 
	j c1_body
c2_cond:
	bne $s6,2, c3_cond		#if else $s6 != 2
	j c2_body
c3_cond:
	bne $s6,3, c4_cond		#if else $s6 != 3
	j c3_body
c4_cond:				#else (no error can accur, taken care earlier) so $s6 == 4
	j c5_body 


c1_body:#check whether it is possible to add
	jal check_add_sub
	

	lw $t0,16($sp)			#load m1*n1 (it is equal to m2*n2)
	mul $t1,$t0,4			#multiplying by 4 to get number of words to store ints
	li $v0, 9			#allocating memory on heap
	move $a0, $t1			#loading 4*m*n
	syscall
	move $t9,$v0			#$t9 address of alocated memory
	sw $t9,($sp)			#saved as loc variable in main
	addiu $sp,$sp,-4		#allocate on stack size of matrix to display( m,n)
	sw $s1,($sp)
	addiu $sp,$sp, -4
	sw $s2, ($sp)
	
add_loop:	
	beqz $t0,cond_end
	#$t5, $t6 temp value of matrices
	lw $t5, ($t7)
	lw $t6, ($t8)
	# $t4 is sum/product of subtraction
	addu $t4,$t5,$t6
	sw $t4, ($t9)
	addiu $t9,$t9,4		#go to the next word of new matrix (change address)
	addiu $t7,$t7,4		#go to the next word of matrix 1 (change address)
	addiu $t8,$t8,4		#go to the next word of matrix 2 (change address)
	addiu $t0,$t0,-1
	j add_loop
c2_body:
	jal check_add_sub
	lw $t0,16($sp)			#load m1*n1 (it is equal to m2*n2)
	mul $t1,$t0,4			#multiplying by 4 to get number of words to store ints
	li $v0, 9			#allocating memory on heap
	move $a0, $t1			#loading 4*m*n
	syscall
	move $t9,$v0			#$t9 address of alocated memory
	sw $t9,($sp)			#saved as loc variable in main
	addiu $sp,$sp,-4		#allocate on stack size of matrix to display( m,n)
	sw $s1,($sp)
	addiu $sp,$sp, -4
	sw $s2, ($sp)
	
sub_loop:
	beqz $t0,cond_end
	nop ################################check this
	#$t5, $t6 temp value of matrix holders
	lw $t5, ($t7)
	lw $t6, ($t8)	
	# $t4 is sum/product of subtraction
	subu $t4,$t5,$t6
	sw $t4,($t9)
	addiu $t9,$t9,4
	addiu $t7,$t7,4
	addiu $t8,$t8,4
	addiu $t0,$t0,-1
	j sub_loop
c3_body:
	jal check_mult
	#allocate space for m1*n2
	mul $t0,$s1,$s4			#size (in words) of new matrix
	mul $t1,$t0,4			#size in bytes of new matrix
	li $v0, 9			#allocating memory on heap
	move $a0, $t1			#loading 4*m*n
	syscall
	move $t9,$v0			#$t9 address of alocated memory
	sw $t9,($sp)			#saved as loc variable in main
	addiu $sp,$sp,-4		#allocate on stack size of matrix to display( m,n)
	sw $s1,($sp)
	addiu $sp,$sp, -4
	sw $s4,($sp)
	#CONVETNITON HERE		loop counters
	move $t2,$s1			#$t2 = m1
	move $t3,$s2			#t3 = n1
	move $s7, $s4			#$s7 = n2
	move $t4,$zero 			#to make sure it's 0



loop_m1:
	beqz $t2,cond_end
	addiu $t2,$t2,-1
#single value loop	
mult_loop_n1:				#$t4 sum which is new element of new matrix
					#$t7 current matrix1 address
					#$t8 current matrix2 address
	beqz $t3,end_n1 #????		if n1 == 0 break and go to end_n2
	addiu $t3,$t3,-1		#n1= n1-1
	lw $t5, ($t7)			#load value from curren matrix1 address v1
	lw $t6, ($t8)			#load value from curren matrix2 address v2
	mul $t0,$t5,$t6			#v1*v2
	add $t4,$t4,$t0			#sum = sum + v1*v2
	addiu $t7,$t7,4			#move current address of matix 1
	mul $t0, $s4,4			#size in bytes to move address of matrix 2 to get to nex elem in column
	add $t8,$t8,$t0
	
	j mult_loop_n1
	
	
end_n1:#end n1
	move $t3, $s2 		#renew n1
	mul $t0, $s2, -4	#restore matrix 1 to the beginning of the row 
	add $t7,$t7,$t0
	
	move $t0, $s3		#this is tricky####check if error accurs
	#addiu $t0,$t0,-1
	mul $t0, $t0, -4
	mul $t0, $s4, $t0	#restore matrix 2 to the beginning of the matrix
	addiu $t0,$t0,4
	add $t8,$t8, $t0	#matrix2 current address = next element (according to prior loop)
	
	sw $t4,($t9)		#save product of addition of multiplication of the each row elem (of matrix 1) and each elem of column of matrix 2
	addiu $t9,$t9,4		#next address of new matrix
	move $t4,$zero
	
	addiu $s7,$s7,-1
	
	
#jump if you have first row output (product of the first row of the matrix)f
	beqz $s7,end_n2		#if(n2 == 0) 
	j mult_loop_n1	
end_n2:	
	#moving matrix 2 back to the beginning of the address
	move $s7, $s4 		#renew n2 so $s7 = $s4 which is n2
	mul $t0,$s2,4 		#move matrix 1 to the next row
	add $t7,$t7,$t0
	lw $t8,12($sp)			#not sure here################################################### need change, it works but is not ellegant form
	j loop_m1
	
#-----------------------------------------------------------------------------NOW NOW NOW	3435533333535355555555555555555555555555555555555555555555555555555555555555555555
c4_body:

#get_cofactor(int *matrix, int * temp, int p, int q, int n)
#where p index of row which won't be copied
#where q index of column which won't be copied
					#stack porinter pointing address of matrix3
	jal check_det	
	#temp alllocation
	move $t0,$s1
	addiu $t1,$t0,-1		
	mul $t0,$t1,$t1			#size of matrix in words

	sll $t0,$t0,2			#size of matrix in bytes
	subu $sp,$sp,$t0 		#allocate space on stack for temp matrix
	#arguments of get_cofactor
	addiu $sp,$sp,-4		#put matrix n on stack
	sw $s1,($sp)
	
	addiu $t0, $zero, 0		#p,q - 0 for check
	addiu $sp,$sp,-4
	sw $t0,($sp)
	addiu $sp,$sp,-4
	sw $t0,($sp)
	
	la $t0,12($sp)			#address of temp matrix (begining of it)
					#convetion i'll follow is: the matrix will be
					#saved from the lowest to the highest address

	addiu $sp,$sp,-4		#put addres of temp on stack
	sw $t0,($sp)
	sw $t0,-16($fp)
	
	addiu $sp,$sp,-4		#put marix address on stack
	lw $t0, -8($fp)			#address of address of matrix is -8($fp)
	sw $t0,($sp)
	
	jal get_cofactor
	addiu $sp,$sp,20		#dealocate space from function args
	lw $t0,-16($fp)			#address of temp
	#lw $t0, 4($sp)			#address of temp
	addiu $sp,$sp,-4
	sw $t0,($sp)
	move $t0,$s1
	addiu $t1,$t0,-1
	addiu $sp,$sp,-4		#allocate on stack size of matrix to display( m,n)
	sw $t1,($sp)
	addiu $sp,$sp,-4		#allocate on stack size of matrix to display( m,n)
	sw $t1,($sp)
	jal print_matrix
	addiu $sp,$sp,12		#dealocating local arg of print_matrix
	#space for temp should be deallocated
	j close_f
	
c5_body:
	jal check_det
	addiu $sp,$sp,-8
	sw $s1,4($sp)			#store n which is this case can be m1 or n1 cause they are the same, and are in $s1, $s2 
	lw $t0,-8($fp)			#load matrix address
	sw $t0,($sp)			#put matrix adddress on stack
	jal get_determinant
	addiu $sp,$sp,8			#dealocate space reverved for get_determinant args
	move $t0,$v0			#get returned value
	li $v0, 1			
	move $a0,$t0
	syscall
	j close_f
	
	
cond_end:		#prep to call print_matrix(m,n,address)
	addiu $sp,$sp,-4
	lw $t3, 12($sp)		#lw $t3,16($fp) will be better
	sw $t3,($sp)		#address
	addiu $sp,$sp,-4
	lw $t3, 8($sp)		#n
	sw $t3,($sp)
	addiu $sp,$sp,-4
	lw $t3, 16($sp)		#m
	sw $t3, ($sp)
	jal print_matrix		#void print_matrix(int m,int n,int *address)
	addiu $sp,$sp,12		#deallocate space reserved for arg of print_matrix
	

close_f:
	li $v0,16		#closing file
	move $a0, $s0		#$a0 = file descriptor
	syscall
	j end
end_err_open:
	li $v0,4		#printing error message
	la $a0,error_open
	syscall
	j end
err_wrong_format:
	li $v0,4		#printing error message
	la $a0,error_format
	syscall
	j end
error_m_n:
	li $v0,4		#printing error message
	la $a0,error_sizes
	syscall
	j end
	
		
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
	mulo  $t0,$t0,10
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
	addiu $sp,$sp,-4		#taking care of return adress and frame pointer 
	sw $ra,0($sp)			#accualy for convention cause I don't use it recursively nor need this two things
	addiu $sp,$sp,-4
	sw $fp,0($sp)
	move $fp,$sp
	#addi $sp,$sp,-4			#store m*n as local variable, since it is argument of the function
	
	
	#addi $sp,$sp,-4			#place for local current addres of allocated memory for matrix
	
	
	lw $t8,12($fp)			#$t8, loop counter, starts at m*n and goes to 0 ten breaks loop
	mul  $t7,$t8,4			#multiplying by 4 to get number of words to store ints
	li $v0, 9			#allocating memory on heap
	move $a0, $t7			#loading 4*m*n
	syscall
	#add $t6,$fp,8
	lw $t6,8($fp)
	#sw $v0,8($fp)			#storing address of memory allocated for matrix
	sw $v0,($t6)
					#in adrress given as *address
	move $t9,$v0			#storing address of memory allocated for matrix, as a place for current address
	
#-----------------------------------------
#reading matrix	
whole_loop:		#loop to get all numbers,
			#whereas the lower ones are to get sigle number
			#$t9 as place for local current addres of allocated memory for matrix
			#$t8, loop counter, starts at m*n and goes to 0 ten breaks loop
	beqz $t8,done
	subiu $t8,$t8,1
			
			
	lbu $t0, ($s5)			#load first char, $s5 current buff adress
	addiu $s5,$s5,1
	beq $t0,'-', negative		#negative number - >jump
	subi $t0,$t0,'0'		#convert to int
pos_loop:
	lbu $t1,($s5)
	addiu $s5,$s5,1
	beqz $t1,end_int_pos		#check if there are more to baits to read
	beq $t1,'\n',end_int_pos
	beq $t1,' ',end_int_pos
	subi $t1,$t1,'0'
	mulo $t0,$t0,10
	add $t0,$t0,$t1
	j pos_loop
end_int_pos:
	
	sw $t0,($t9)
	addiu $t9,$t9,4
	move $t0,$zero
	move $t1,$zero
	j whole_loop
	
	
negative:
	lbu $t0, ($s5)			#start reading digits
	addiu $s5,$s5,1
	subi $t0,$t0,'0'		#convert to int
neg_loop:	
	lbu $t1,($s5)
	addiu $s5,$s5,1
	beqz $t1,end_int_neg		#check if there are more to baits to read
	beq $t1,'\n',end_int_neg
	beq $t1,' ',end_int_neg
	subi $t1,$t1,'0'
	mulo $t0,$t0,10
	add $t0,$t0,$t1
	j neg_loop
end_int_neg:
	mul $t0,$t0, -1			#getting negative
	sw $t0,($t9)
	addiu $t9,$t9,4
	move $t0,$zero
	move $t1,$zero
	j whole_loop
	
	
done:	
	#addiu $sp,$sp,8		
	move $sp,$fp			#dealocting space for $ra and $fp
	lw $fp,($sp)
	addiu $sp,$sp, 4
	lw $ra,($sp)
	addiu $sp,$sp, 4
	jr $ra
	

	
#	li $v0,1		#printing file descriptor
#	move $a0, $t0
#	syscall
#----------------------------------
print_endl:
	li $v0,4		#printing \n
	la $a0, endl
	syscall
	jr $ra
print_space:
	li $v0,4		#printing ' '
	la $a0, space
	syscall
	jr $ra

	
	
#function get operation typ operation_type(int * buf_address) where $s5 have buf address
get_operation_type:
	#addiu $sp,$sp,-4
	#sw $ra,($sp)
	lbu $t0, ($s5)			#load first char
	addiu $s5,$s5,1
	beq $t0, '+', addition
	beq $t0, '-', subtraction
	beq $t0, '*', multiplication
	beq $t0 'd', determinant
	j err_wrong_format
addition:
	li $s6, 1
	j op_end
subtraction:
	li $s6, 2
	j op_end
multiplication:
	li $s6, 3
	j op_end
determinant:
	li $s6, 4		#'d' already read, but 'e' 't'
	addiu $s5,$s5,2		
	j op_end
	
op_end:				
	addiu $s5,$s5,1		#moving after '\n'
	jr $ra
	
	
# fuction print_matrix(int* matrix_begin, int m, int n):
#

check_add_sub:
	bne $s1,$s3,error_m_n
	bne $s2,$s4,error_m_n
	jr $ra
check_mult:
	bne $s2,$s3,error_m_n
	jr $ra
check_det:
	bne $s1,$s2,error_m_n
	jr $ra
	
	
	
	
	
	
	
print_matrix:	#print matrix (m,n, address)
	addiu $sp,$sp,-4
	sw $ra,($sp)
	addiu $sp,$sp, -4
	sw $fp,($sp)
	move $fp,$sp
	#tu jest cos zle
	lw $t0,8($fp)		#m
	lw $t1,12($fp)		#n
	lw $t2,16($fp)		#address
fori:	#go until m=0
	beqz $t0,end_printing
	addiu $t0,$t0,-1
forj:	#go until n=0
	beqz $t1, end_forj
	addiu $t1,$t1,-1
	li $v0, 1			#printing sigle element
	lw $a0, ($t2)
	syscall
	addiu $t2,$t2,4
	
	
	jal print_space
	j forj
end_forj:
	lw $t1,12($fp)		#n renewed
	jal print_endl
	j fori
	
	
end_printing:

	#lw $ra,4($fp)
	move $sp,$fp
	lw $fp,($sp)
	addiu $sp,$sp,4
	lw $ra,($sp)
	addiu $sp,$sp,4
	jr $ra


	
	
###############################################################################
#get_cofactor(int *address_matrix, int * temp, int p, int q, int size)
#where p index of row which won't be copied
#where q index of column which won't be copied
#it has local variables, but it won't be called recursively
#so they are not put on stack for conviniece, only registers are being used
get_cofactor:	
	addiu $sp,$sp,-4
	sw $ra, ($sp)
	addiu $sp,$sp,-4
	sw $fp,($sp)
	move $fp,$sp
	
	move $t0,$zero			# $t0 = i = 0
	move $t1,$zero			# $t1 = j = 0
	move $t2,$zero			# $t2 = row = 0
	lw $t4,24($fp)			#$t4 = n; it will stay const
	lw $t5,16($fp)			#$t5 = p
	lw $t6,20($fp)			#t6 = q
	lw $t7,8($fp)			#t7 = address of matrix
	lw $t8,12($fp)			#$t8 = address of temp
	addiu $s7,$t4,-1		#n of temp = n -1 

	beq $t2,$t4,not_loop1_get_cofactor	#  for (int row = 0; row < n; row++) 
loop1_get_cofactor:

	move $t3,$zero				#$t3 = col = 0
	beq $t3,$t4,end_loop1_get_cofactor	#   for (int col = 0; col < n; col++) 
loop2_get_cofactor:
	
if1_get_cofactor:	
	beq $t2,$t5, end_ifs_get_cofactor	# if (!(row==p || col==q))
	beq $t3,$t6, end_ifs_get_cofactor
	#temp 
	mul $t9, $s7, $t0			#go to index ith row, so i * size (in words)
	add $t9,$t9,$t1				#go to the correct column
	sll $t9,$t9,2				#multiply by 4 (shifting 2 bits left)
	add $t8,$t8,$t9				#store correct address
	move $t9,$zero
	#matrix
	mul $t9, $t4, $t2			#go to index ith row, so row * size (in words)
	add $t9,$t9,$t3			#go to the correct column
	sll $t9,$t9,2				#multiply by 4 (shifting 2 bits left)
	add $t7,$t7,$t9				#store correct address
	
	lw $t9,($t7)				#$t9 = mat[row][col]; 
	sw $t9,($t8)				#temp[i][j] = $t9
	addiu $t1,$t1,1				#j++
	lw $t7,8($fp)				#t7 = address of matrix back to beginning
	lw $t8,12($fp)				#$t8 = address of temp back to beginning
if2_get_cofactor:				
	addiu $t9,$t4,-1			# if (j == n - 1) 
	bne $t1, $t9, end_ifs_get_cofactor
	move $t1,$zero				#j=0	
	addiu $t0,$t0,1				#i++
end_ifs_get_cofactor:
	addiu $t3,$t3,1				#col++
	blt $t3,$t4,loop2_get_cofactor		#   for (int col = 0; col < n; col++)
end_loop1_get_cofactor:
	addiu $t2,$t2,1				#row++
	blt $t2,$t4,loop1_get_cofactor		#  for (int row = 0; row < n; row++)
not_loop1_get_cofactor:	
	move $sp,$fp				#end of the function
	lw $fp,($sp)
	addiu $sp,$sp,4
	lw $ra,($sp)
	addiu $sp,$sp,4
	jr $ra

#FUNCTION int determinant(int address_matrix, int n), return in $v0, n = matix's dimmention
#convetion
#$t0 = n
get_determinant:
	addiu $sp,$sp,-4
	sw $ra, ($sp)
	addiu $sp,$sp,-4
	sw $fp,($sp)
	move $fp,$sp
	
	
	
	
	#if (n==1) return matrix[0][0]
	lw $t0, 12($fp)			#$t0 = n
	bne $t0,1,not_if_get_determinant
	lw $t1, 8($fp)			#address of matrix
	#lw $t9,($t1)
	lw $v0, ($t1)			#return $v0 = matrix 1x1 (i.e.single element)
	move $sp,$fp
	lw $fp,($sp)
	addiu $sp,$sp,4
	lw $ra,($sp)
	addiu $sp,$sp,4
	jr $ra
	
not_if_get_determinant:
	addiu $sp,$sp,-20		#local variables
					#int D; int * address_of_temp; int sign = 1; int f = 0; int size_in_bytes;
	sw $zero,-4($fp)		#D = 0
	addiu $t1,$zero,1		
	sw $t1,-12($fp)			#sign = 1;
	sw $zero,-16($fp)		#f = 0;
	
	
	#int temp[n-1][n-1]
	addiu $t1,$t0,-1		#dimention of temp: n-1
	mul $t1,$t1,$t1			#size of temp in words 
	sll $t1,$t1,2			#size of temp in bytes
	sw $t1,-20($fp)			#store size of temp in bytes
	subu $sp,$sp,$t1		#allocate space for temp
	la $t1,($sp)			#$t1 = address of address of temp 
	sw $t1,-8($fp)			#address_of_temp = $t1
	
	
	lw $t1,-16($fp)			#$t1 = f
	bge $t1 ,$t0,not_loop_get_determinant
loop_get_determinant:
	#put args of get_cofactor on stack
	addiu $sp,$sp,-20
	lw $t9,8($fp)			#load address of matrix
	sw $t9, ($sp)			#put address of matrix on sack
	lw $t9, -8($fp)			#load address of temp
	sw $t9, 4($sp)			#put addres of temp on stack
	sw $zero,8($sp)			#put p=0 on stack; each funtion will be called to count
					#cofactor of row =0, col will differ
	lw $t1,-16($fp)			#$t1 = f
	sw $t1,12($sp)			#store q = f on stack, !!!!!caution potential bug if in lines abouve $t1 was used, and change value from f
	lw $t0, 12($fp)			#$t0 = n
	sw $t0, 16($sp)			#store n = n dimmention of matrix to get cofactor of
	jal get_cofactor
	addiu $sp,$sp,20		#dealocate space from get_cofactor args
	#call get_determinant recursively
	#prep args for get_determinant
	addiu $sp,$sp,-8
	lw $t0, 12($fp)			#$t0 = n
	addiu $t0,$t0,-1		#$t0 = n -1
	sw $t0,4($sp)			#put n-1 on stack
	lw $t9, -8($fp)			#load address of temp
	sw $t9, ($sp)			#put addres of temp on stack
	jal get_determinant
	addiu $sp,$sp, 8		#it can be done here cause it will executed only for 1x1 matrix so no space for matrix will be unwillingly deallocated
	#sw $v0, -24($fp)		#a = what get_determinant's returned
	lw $t0, -12($fp)		#load sign
	#load mat[0][f]
	lw $t1, -16($fp)		#load f
	move $t9,$t1			#get copy of f for later use
	sll $t1,$t1,2			#4*f; multiply by 4 to get how far move mat address
	lw $t2,8($fp)			#load beginnig of matrix
	add $t2,$t2,$t1		#get correct address of matrix to get value from 
					#&m + 4*n*i*0 + 4*j where m[i][j] and dimmention n
	lw $t3,($t2)			#get m[0][f]	
	lw $t4, -4($fp)			#load D
	mul $t5,$t0,$t3			#$t5 = sign* mat[0][f];
	mul $t5,$t5,$v0			#$t5 = $t5*a;
	add $t4,$t4,$t5			#$t4 = $t4 + $t5 which translates into d = d + $t5
	sw $t4,-4($fp)			#acutalize D on stack			
	mul $t0,$t0,-1			#sign = -sign #######this made a mistake
	sw $t0,-12($fp)			#acutualize sign on stack
	addiu $t9,$t9,1			#f++
	sw $t9, -16($fp)		#actualize f on stack
	lw $t8, 12($fp)			#$t8 = n
	blt $t9,$t8,loop_get_determinant
	
not_loop_get_determinant:
	lw $v0, -4($fp)			#$v0 = D it will be returned
	move $sp,$fp			#dealocated local variables, does it deallocates also temp matrix????
	lw $fp,($sp)	
	addiu $sp,$sp,4
	lw $ra,($sp)
	addiu $sp,$sp,4
	jr $ra
	

	
	
	
	
	
	
				
