# Various macro definitions
	.macro	POP dst
	subl	$4, %esi
	movl	(%esi), \dst
	.endm

	.macro	POP2 dst1 dst2
	POP	\dst1
	POP	\dst2
	.endm
	
	.macro	PUSH dst
	movl	\dst, (%esi)
	addl	$4, %esi
	.endm

	.macro	BYTE dst
	movb	(%edi), \dst
	inc	%edi
	.endm

	.macro	WORD dst
	movl	(%edi), \dst
	addl	$4, %edi
	.endm

	.macro	B lab
	movl	.+BAR-FOO, %ecx
	jmp	\lab
	.endm

	.macro	GB
	jmp (%ecx)
	.endm
	
	.global eval
	.data
# Format string for debugging	
fmt:	.string "%x\n"

# Stack space
stack:	.zero 512

	.text
FOO:	
	movl $0, %ecx
	jmp  FOO
BAR:	nop
	
# Taking the pointer to the bytecode buffer
# as an argument
	
eval:
# Saving callee's frame pointer
	pushl	%ebp

# Moving bytecode pointer to %edi
# %epb now plays a role of instruction
# pointer	
	movl	8(%esp), %edi

# Moving stack address to %esi
# %esi now plays a role of stack pointer	
	movl	$stack, %esi

	xorl	%eax, %eax	
	BYTE	%al

	movb	%al,%ah
	andb    $0x0F,%al
	andb    $0xF0,%ah
	shrb	$4,%ah

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
	
binops:	.int b_add,b_sub,b_mul,b_mod
