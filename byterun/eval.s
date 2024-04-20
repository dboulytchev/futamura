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

	.macro	INT dst
	movl	(%edi), \dst
	addl	$4, %edi
	.endm

	.global eval
	.data
# Format string for debugging
fmt:	.string "%x\n"
instr_begin: .int 0

# Stack space
stack:	.zero 512

	.text

# Taking the pointer to the bytecode buffer
# as an argument

eval:
# Saving callee's frame pointer
	pushl	%ebp

# Moving bytecode pointer to %edi
# %epb now plays a role of instruction
# pointer
	movl	8(%esp), %edi
	movl 	%edi, instr_begin

# Moving stack address to %esi
# %esi now plays a role of stack pointer
	movl	$stack, %esi

entry_point:
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
	ret

b_sub:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB %ebx
	subl	%eax, %ebx
	FIX_BOX %ebx
	PUSH	%ebx
	ret

b_mul:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB %ebx
	imul	%ebx
	FIX_BOX %eax
	PUSH	%eax
	ret

b_div:	POP2	%ebx %eax
	FIX_UNB %eax
	FIX_UNB %ebx
	cltd
	idiv	%ebx
	FIX_BOX %eax
	PUSH	%eax
	ret

b_mod:	POP2	%ebx %eax
	FIX_UNB %eax
	FIX_UNB %ebx
	cltd
	idiv	%ebx
	FIX_BOX %edx
	PUSH	%edx
	ret

b_eq: 	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB %ebx
	xorl	%edx, %edx
	cmpl	%eax, %ebx
	xorl 	%eax, %eax
	seteb	%dl
	FIX_BOX %edx
	PUSH 	%edx
	ret

b_neq: 	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB %ebx
	xorl	%edx, %edx
	cmpl	%eax,%ebx
	setneb	%dl
	FIX_BOX %edx
	PUSH 	%edx
	ret

b_lt: 	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	xorl	%edx, %edx
	cmpl	%eax, %ebx
	setlb	%dl
	FIX_BOX %edx
	PUSH	%edx
	ret

b_le:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	xorl	%edx, %edx
	cmpl	%eax, %ebx
	setleb	%dl
	FIX_BOX %edx
	PUSH	%edx
	ret

b_gt: 	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	xorl	%edx, %edx
	cmpl	%eax, %ebx
	setgb	%dl
	FIX_BOX %edx
	PUSH	%edx
	ret

b_ge:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	xorl	%edx, %edx
	cmpl	%eax, %ebx
	setgeb	%dl
	FIX_BOX %edx
	PUSH	%edx
	ret

b_and:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	andl	%eax, %ebx
	FIX_BOX %ebx
	PUSH	%ebx
	ret

b_or:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	orl		%eax, %ebx
	FIX_BOX %ebx
	PUSH	%ebx
	ret

binops:	.int b_add,b_sub,b_mul,b_div,b_mod,b_eq,b_neq,b_lt,b_le,b_gt,b_ge,b_and,b_or

/* some trivial binops */

bc_drop:
	POP %eax
	ret

bc_dup:
	POP 	%eax
	PUSH	%eax
	PUSH	%eax
	ret

bc_const:
	FIX_BOX	%ecx
	PUSH 	%ecx
	ret

bc_line:
	nop
	ret

bc_fail:
	pushl	$scanline
	call	failure
	popl	%eax
	ret

bc_ldg:
	movl	global_data(, %ecx, 4), %eax
	PUSH	%eax
	ret

bc_ldl:
	negl	%ecx
	movl	-4(%ebp, %ecx, 4), %eax
	PUSH	%eax
	ret

bc_lda:
	/*  Maybe it should be 8, not 4 (resolve on merging vs Call)  */
	movl	4(%ebp, %ecx, 4), %eax
	PUSH	%eax
	ret

bc_stg:
	POP		%eax
	movl	%eax, global_data(, %ecx, 4)
	ret

bc_stl:
	negl	%ecx
	POP		%eax
	movl	%eax, -4(%ebp, %ecx, 4)
	ret

bc_sta:
	POP		%eax
	/*  Maybe it should be 8, not 4 (resolve on merging vs Call)  */
	movl	%eax, 4(%ebp, %ecx, 4)
	ret

	.data
scanline: .asciz "something bad happened"
global_data: .skip 4 * 1000
i_cjmpz: POP	%eax
	FIX_UNB	%eax
	addl	instr_begin, %ecx
	testl	%eax, %eax
	je	not_go1
	movl	%ecx, %edi
not_go1:
	ret

i_cjmpnz: POP	%eax
	FIX_UNB	%eax
	addl	instr_begin, %ecx
	testl	%eax, %eax
	jne	not_go2
	movl	%ecx, %edi
not_go2:
	ret

i_jmp:
	addl	instr_begin, %ecx
	movl	%ecx, %edi
	ret


