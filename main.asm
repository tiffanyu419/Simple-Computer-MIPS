#This program checks for validity of a user input and then evaluates a simple algebraic expression
#Written by Tiffany Yu

.data
inputString: .space 64
prompt1: .asciiz "Enter algebraic expression (max 2 operations): "
ans: .asciiz "Ans: "
space: .asciiz "\n"
invalid: .asciiz "Invalid input \n"
variable: .asciiz "Variable saved \n"
integer: .space 64
operations: .space 64
variables: .space 64

.text
main:	
	li	$s3, 0 	#len of variable list
	j	other_main
	
other_main:
	#Asks user for input
	la	$a0, prompt1 
	li	$v0, 4
	syscall
	la	$a0, inputString
	la	$a1, inputString 
	li	$v0, 8
	syscall
	la	$a0, inputString
	li	$s4, 0 	#counter for reading string
	li	$t3, 0	#flag for equal signs
	li	$t5, 0 	#flag for int 
	li	$t6, 0 	#flag for add/subtract
	li	$t7, 0 	#counter for parenthesis
	li	$t8, 0 	#flag for mult/div (reading)
	li	$t9, 0	#flag for alphabet
	li	$s5, 0  #flag for end of string
	li	$s6, 0  #length of operation stack
	li	$s7, 0 	#flag for mult/div (calculation)
	la	$s0, integer
	la	$s1, operations 
	la	$s2, variables
	j	read_string
	
read_string:
	#reset $t2 everytime
	li	$t2, 1
	#Reads string and checks if specific character is valid
	add	$t0, $s4, $a0	#adds to address
	lhu	$t1, 0($t0)	#saves character in $t1
	#check if end of string
	beq	$t1, 10, endstring
	#check if invalid characters
	slti	$t2, $t1, 32  
	beq	$t2, 1, print_invalid
	#check if space
	seq	$t2, $t1, 32   
	beq	$t2, 1, blank
	#check if operation
	slti	$t2, $t1, 48  
	beq	$t2, 1, operation
	#check if integer
	slti	$t2, $t1, 58
	beq	$t2, 1, int
	#check if invalid characters
	slti	$t2, $t1, 65  
	beq	$t2, 1, operation
	#check if upper case alphabet
	slti	$t2, $t1, 91
	beq	$t2, 1, alphabet
	#check if invalid characters
	slti	$t2, $t1, 97
	beq	$t2, 1, print_invalid
	#check if lower case alphabet
	slti	$t2, $t1, 123
	beq	$t2, 1, alphabet
	#if none of the above then
	j	print_invalid

endstring:
	#check if equal flag is up
	beq	$t3, 1, saved_var
	#check if alphabet flag is up
	beq	$t9, 1, load_var
	#reset flag
	li	$t4, 0
	#check if all parenthesis are closed
	sgt	$t4, $t7, 0
	beq	$t4, 1, print_invalid
	#check if mult/div is up
	beq	$t8, 1, print_invalid
	#check if add/sub is up
	beq	$t6, 1, print_invalid
	#check if there is still operations in operations stack
	bne	$s6, 0, calculate
	#else
	j 	print

saved_var:
	#sets flag for saving variable to one
	li	$t4, 1
	#prints saved variable message
	la	$a0, variable
	li	$v0, 4
	syscall
	j	other_main
blank:
	#increment counter by 1 and jump back to the start of read string
	addi 	$s4, $s4, 1
	j	read_string

operation:
	#check if equal flag is up
	beq	$t3, 1, print_invalid
	#check if parenthesis
	beq	$t1, 40, open_p
	beq	$t1, 41, close_p
	#check if other operations
	beq	$t1, 43, add_sub 	#addition
	beq	$t1, 45, add_sub	#subtraction
	beq	$t1, 42, mult_div	#mult
	beq	$t1, 47, mult_div	#div
	#check if equal sign
	beq	$t1, 61, equal
	#else
	j	print_invalid

load_var:
	# if variable dne
	beq	$v0, 0, print_invalid
	# push integer into stack
	addi	$s0, $s0, -4
	sh	$v0, 0($s0)
	li	$v0, 0
	li	$t9, 0
	li	$t5, 1
	j	read_string
	
open_p:
	#check if mult_div flag is up
	beq	$t8, 1, valid_op
	#check if add_sub flag is up
	beq	$t6, 1, valid_op
	#check if start of line
	beq	$s4, 0, valid_op
	#else:
	j	print_invalid

close_p:
	#reset flag 
	li	$t4, 2
	#check if there was an open parenthesis
	div	$t7, $t4
	mfhi	$t4
	beq	$t4, 1, valid_cp
	#check if mult_div flag is up
	beq	$t8, 1,  print_invalid
	#check if add_sub flag is up
	beq	$t6, 1,  print_invalid
	#else
	j	valid_cp

valid_op:
	#add one to parenthesis flag
	add	$t7, $t7, 1
	#set all other flags to zero
	li	$t5, 0 	#flag for int
	li	$t6, 0 	#flag for add/subtract
	li	$t8, 0	#flag for mult_div
	li	$t9, 0	#flag for alphabet
	#increment counter by 1 and jump back to the start of read string
	addi 	$s4, $s4, 1
	j	read_string

valid_cp:
	#subtract one from parenthesis flag
	sub 	$t7, $t7, 1
	#set all other flags to zero
	li	$t5, 0 	#flag for int
	li	$t6, 0 	#flag for add/subtract
	li	$t8, 0	#flag for mult_div
	li	$t9, 0	#flag for alphabet
	#increment counter by 1 and jump back to the start of read string
	addi 	$s4, $s4, 1
	j	calculate

add_sub:
	#set $t4 to equal 2
	li	$t4, 2
	#check if mult_div flag is up
	beq	$t8, 1, print_invalid
	#if add_sub flag is up 
	beq	$t6, 1, valid_addsub
	#if int flag is up 
	beq	$t5, 1, valid_addsub
	#if alphabet flag is up 
	beq	$t9, 1, valid_addsub
	#check if start of string
	beq	$s4, 0, print_invalid
	#check if parenthesis just ended
	div	$t7, $t4
	mfhi	$t4
	beq	$t4, 0, valid_addsub
	#else
	j	print_invalid

valid_addsub:
	#check if prev character was a variable
	beq	$t9, 1, load_var 
	#check if div or mult flag is up. If up go calculate (does not save this operation)
	bgt	$s7, 0, calculate
	#else save operation
	addi 	$s1, $s1, -4
	sh 	$t1, 0($s1)	
	addi	$s6, $s6, 1	#increment size of operation by 1
	#set add_sub flag to 1
	li	$t6, 1
	#set all other flags to zero
	li	$t5, 0 	#flag for int
	li	$t8, 0 	#flag for mult_div
	li	$t9, 0	#flag for alphabet
	#increment counter by 1 and jump to read string
	addi 	$s4, $s4, 1
	j	read_string

mult_div:
	#check if int flag is up
	beq	$t5, 1, valid_multdiv
	#check if alphabet flag is up
	beq	$t9, 1, valid_multdiv
	#check if start of string
	beq	$s4, 0, print_invalid
	#check if parenthesis just ended
	li	$t4, 2
	div	$t7, $t4
	mfhi	$t4
	beq	$t4, 0, valid_multdiv
	#else
	j	print_invalid

valid_multdiv:
	#check if prev character was a variable
	beq	$t9, 1, load_var
	#else save operation
	addi 	$s1, $s1, -4
	sh 	$t1, 0($s1)	
	addi	$s6, $s6, 1	#increment size of operation by 1
	#set both mult_div flag to 1
	li	$t8, 1
	addi 	$s7, $s7, 1
	#set all other flags to zero
	li	$t5, 0 	#flag for int
	li	$t6, 0 	#flag for add/subtract
	li	$t9, 0	#flag for alphabet
	#increment counter by 1 and jump back to the start of read string
	addi 	$s4, $s4, 1
	j	read_string

equal: 
	#check if alphabet flag is up
	beq	$t9, 0, print_invalid
	#put equal sign up
	li	$t3, 1
	#put other flags to zero
	li	$t5, 0 	#flag for int 
	li	$t6, 0 	#flag for add/subtract
	li	$t8, 0 	#flag for mult/div (reading)
	li	$t9, 0	#flag for alphabet
	#increment counter by 1 and jump to read string
	addi 	$s4, $s4, 1
	j	read_string
	
int:
	#Convert string character to int
	add	$t1,$t1, -48
	#check if alphabet flag is up
	beq	$t9, 1, print_invalid
	#check if equal flag is up
	beq	$t3, 1, save_val
	#check if all other flags are zero
	beq	$t5, 1, valid_int
	beq	$s4, 0, valid_int
	beq	$t6, 1, valid_int
	beq	$t8, 1, valid_int
	beq	$t3, 1, valid_int
	#check if there was an open parenthesis
	li	$t4, 2
	div	$t7, $t4
	mfhi	$t4
	beq	$t4, 1, valid_int
	#else
	j 	print_invalid	
	
valid_int:
	#check if int flag is up
	beq	$t5, 1, combine
	# push integer into stack
	addi	$s0, $s0, -4
	sh	$t1, 0($s0)
	#set int flag to 1
	li	$t5, 1
	#set all other flags to zero
	li	$t6, 0 	#flag for add/subtract
	li	$t8, 0 	#flag for mult/div
	li	$t9, 0	#flag for alphabet
	#increment counter by 1 and jump back to the start of read string
	addi 	$s4, $s4, 1
	j	read_string
	
combine:
	#pops latest int off stack and save to $t0
	lh	$t0, 0($s0)
	addi 	$s0, $s0, 4
	#multiplies number in register and add current int to it
	mul	$t0, $t0, 10
	add	$t0, $t0, $t1
	# push integer back into stack
	addi	$s0, $s0, -4
	sh	$t0, 0($s0)
	li	$t5, 1 		#flag is for int is set to 1
	#increment counter by 1 and jump back to the start of read string
	addi 	$s4, $s4, 1
	j	read_string

save_val:
	#check if int flag is up
	beq	$t5, 0, first_val
	#saves original value into $t0
	add	$t2, $s2, $v1
	lh	$t0, 0($t2)
	#multiplies number in register and add current int to it
	mul	$t0, $t0, 10
	add	$t0, $t0, $t1
	# push integer back into stack
	sh	$t0, 0($t2)
	li	$t5, 1 		#flag is for int is set to 1
	#set all other flags to zero
	li	$t6, 0 	#flag for add/subtract
	li	$t8, 0 	#flag for mult/div
	li	$t9, 0	#flag for alphabet
	#increment counter by 1 and jump back to the start of read string
	addi 	$s4, $s4, 1
	j	read_string

first_val:
	# push integer into stack
	add	$t2, $s2, $v1
	sh	$t1, 0($t2)
	#set int flag to 1
	li	$t5, 1
	#set all other flags to zero
	li	$t6, 0 	#flag for add/subtract
	li	$t8, 0 	#flag for mult/div
	li	$t9, 0	#flag for alphabet
	#increment counter by 1 and jump back to the start of read string
	addi 	$s4, $s4, 1
	j	read_string
alphabet:
	#check if equal flag is up
	beq	$t3, 1, print_invalid
	#check if alphabet flag is up
	beq	$t9, 1, print_invalid
	#check if int flag is up
	beq	$t5, 1, print_invalid
	#check if start of line
	beq	$s4, 0, valid_alphabet
	#check if mult_div flag is up
	beq	$t8, 1, valid_alphabet
	#check if add_sub flag is up
	beq	$t6, 1, valid_alphabet
	#check if there was an open parenthesis
	li	$t4, 2
	div	$t7, $t4
	mfhi	$t4
	beq	$t4, 1, valid_alphabet
	#else
	j	print_invalid

valid_alphabet:
	add	$t4, $s3, $zero		#counter for while loop. $t4 amount of variables available
	sll	$t4, $t4, 2		
	j	find_val
	
find_val: #while loop
	#find if alphabet already exists
	beq	$t4, 0, new_var
	add	$t2, $t4, $s2
	lh	$t2, 0($t2)
	beq	$t1, $t2, var_exist
	addi	$t4, $t4, -4		#start at the bottom of stack go back up 
	j	find_val
	
var_exist:
	add	$t2, $t1, $s2
	lh	$v0, 0($t2)		#save value of character in v0
	# push integer into stack
	addi	$s0, $s0, -4
	sh	$v0, 0($s0)		#value of variable saved in stack
	li	$t5, 1 			#flag is for int is set to 1
	addi 	$v1, $t1, 0		#save character in v1
	#update flags
	li	$t9, 0			#flag of alphabet
	li	$t6, 0 			#flag for add/subtract
	li	$t8, 0			#flag for mult_div
	#increment counter by 1 and jump back to the start of read string
	addi 	$s4, $s4, 1
	j 	read_string
	
new_var:
	# push variable into stack
	addi 	$s3, $s3, 1
	sll	$t4, $s3, 2
	add	$t4, $t4, $s2
	sh	$t1, 0($t4)
	# save character
	addi 	$v1, $t1, 0
	#set alphabet flag to 1
	li	$t9, 1
	#set all other flags to zero
	li	$t6, 0 	#flag for add/subtract
	li	$t8, 0 	#flag for mult/div
	li	$t5, 0	#flag for alphabet
	#increment counter by 1 and jump back to the start of read string
	addi 	$s4, $s4, 1
	j	read_string

calculate:
	#pops first operation off stack save to $t0
	lh	$t0, 0($s1)
	addi 	$s1, $s1, 4
	addi	$s6, $s6, -1	#decrease size of operation by 1
	#pops the first two integers off stack and save to $t1 and $t2
	lh	$t1, 0($s0) #cannot load more more than 3 bits?
	addi 	$s0, $s0, 4
	lh	$t2, 0($s0)
	addi 	$s0, $s0, 4
	#Compares user input of operation to numbers in order to jump to correct function
	beq	$t0, 43, addition
	beq	$t0, 45, subtraction
	beq	$t0, 42, multiplication
	beq	$t0, 47, division
	
addition:
	#adds the two numbers and saves to $t1
	add	$t1, $t1, $t2
	# push integer into stack
	addi	$s0, $s0, -4
	sh	$t1, 0($s0)
	# jumps back to read_string
	j 	read_string

subtraction:
	#subtracts the two numbers together and saves to $t1
	sub 	$t1, $t2, $t1
	# push integer into stack
	addi	$s0, $s0, -4
	sh	$t1, 0($s0)
	# jumps back to read_string
	j 	read_string
multiplication:
	#multiplies the two numbers together and saves to $t1
	mul	$t1, $t1, $t2
	# push integer into stack
	addi	$s0, $s0, -4
	sh	$t1, 0($s0)
	# sets mult and div flag back to zero and jumps back to read_string
	subi	$s7, $s7, 1 
	j 	read_string

division:
	#divides the two numbers together and saves to $t1
	div   	$t2, $t1
	mflo	$t1 	
	# push integer into stack
	addi	$s0, $s0, -4
	sh	$t1, 0($s0)
	# sets mult and div flag back to zero and jumps back to read_string
	subi	$s7, $s7, 1
	j 	read_string

print:
	#prints answer
	la	$a0, ans
	li	$v0, 4
	syscall
	#pops the last int in the stack sand saves into $a0
	lh	$a0, 0($s0)
	addi 	$s0, $s0, 4
	#prints
	li	$v0, 1
	syscall
	la	$a0, space
	li	$v0, 4
	syscall
	#returns to main
	j	other_main

print_invalid:
	#prints invalid
	la	$a0, invalid
	li	$v0, 4
	syscall
	#returns to main
	j	main
	

