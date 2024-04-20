# Various macro definitions
# fixnum arithmetics: make box for an integer
	.macro FIX_BOX dst
	sall 	$1, \dst
	xorl 	$1, \dst
	.endm

# fixnum arithmetics: unbox integer
	.macro FIX_UNB dst
	xorl 	$1, \dst
	sarl 	$1, \dst
	.endm

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
	andb    $15,%al
	andb    $240,%ah
	shrb 	$4,%ah

# Restoring callee's frame pointer
	popl	%ebp

# Returning	
	ret

b_add:	POP2 	%eax %ebx
	FIX_UNB %eax
	FIX_UNB %ebx
	addl	%ebx, %eax
	FIX_BOX %eax
	PUSH	%eax

b_sub:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB %ebx
	subl	%eax, %ebx
	FIX_BOX %ebx
	PUSH	%ebx

b_mul:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB %ebx
	imul	%ebx
	FIX_BOX %eax
	PUSH	%eax

b_div:	POP2	%ebx %eax
	FIX_UNB %eax
	FIX_UNB %ebx
	cltd
	idiv	%ebx
	FIX_BOX %eax
	PUSH	%eax

b_mod:	POP2	%ebx %eax
	FIX_UNB %eax
	FIX_UNB %ebx
	cltd
	idiv	%ebx
	FIX_BOX %edx
	PUSH	%edx

b_eq: 	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB %ebx
	xorl	%edx, %edx
	cmpl	%eax, %ebx
	xorl 	%eax, %eax
	seteb	%dl
	FIX_BOX %edx
	PUSH 	%edx

b_neq: 	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB %ebx
	xorl	%edx, %edx
	cmpl	%eax,%ebx
	setneb	%dl
	FIX_BOX %edx
	PUSH 	%edx

b_lt: 	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	xorl	%edx, %edx
	cmpl	%eax, %ebx
	setlb	%dl
	FIX_BOX %edx
	PUSH	%edx

b_le:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	xorl	%edx, %edx
	cmpl	%eax, %ebx
	setleb	%dl
	FIX_BOX %edx
	PUSH	%edx

b_gt: 	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	xorl	%edx, %edx
	cmpl	%eax, %ebx
	setgb	%dl
	FIX_BOX %edx
	PUSH	%edx

b_ge:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	xorl	%edx, %edx
	cmpl	%eax, %ebx
	setgeb	%dl
	FIX_BOX %edx
	PUSH	%edx

b_and:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	andl	%eax, %ebx
	FIX_BOX %ebx
	PUSH	%ebx

b_or:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	orl		%eax, %ebx
	FIX_BOX %ebx
	PUSH	%ebx

binops:	.int b_add,b_sub,b_mul,b_div,b_mod,b_eq,b_neq,b_lt,b_le,b_gt,b_ge,b_and,b_or
