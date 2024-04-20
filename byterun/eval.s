# Various macro definitions
	.macro	POP dst
	movl	(%esi), \dst
	subl	$4, %esi
	.endm

	.macro	POP2 dst1 dst2
	POP	\dst1
	POP	\dst2
	.endm
	
	.macro	PUSH dst
	addl	$4, %esi
	movl	\dst, (%esi)
	.endm

	.macro	BYTE dst
	movb	(%ebp), \dst
	inc	%ebp
	.endm

	.macro	WORD dst
	movl	(%ebp), \dst
	addl	$4, %ebp
	.endm

	.global eval
	.data
# Format string for debugging	
fmt:	.string "%x\n"

# Stack space
stack:	.zero 512
	
	.text
# Taking the pointer to the bytecode buffer
# as an argument
	
eval:
# Saving callee's frame pointer
	pushl	%ebp

# Moving bytecode pointer to %ebp
# %epb now plays a role of instruction
# pointer	
	movl	8(%esp), %ebp

# Moving stack address to %esi
# %esi now plays a role of stack pointer	
	movl	$stack, %esi

	xorl	%eax, %eax
	
	BYTE	%al

	pushl 	%eax
	pushl	$fmt
	call	printf
	addl	$8, %esp

	xorl	%eax, %eax
	
	BYTE	%al

	pushl 	%eax
	pushl	$fmt
	call	printf
	addl	$8, %esp

# Restoring callee's frame pointer
	popl	%ebp

# Returning	
	ret

b_add:	POP2 	%eax %ebx
	addl	%ebx, %eax
	PUSH	%eax

b_sub:	POP2	%eax %ebx
	subl	%eax, %ebx
	PUSH	%ebx

b_mul:	POP2	%eax %ebx
	imul	%ebx
	PUSH	%eax

b_div:	POP2	%ebx %eax
	cltd
	idiv	%ebx
	PUSH	%eax

b_mod:	POP2	%ebx %eax
	cltd
	idiv	%ebx
	PUSH	%edx
	
w:	.word b_abb, b_sub, b_mul, b_mod
