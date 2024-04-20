# Various macro definitions
# fixnum arithmetics: make box for an integer
	.macro FIX_BOX dst
	sall 	$1, \dst
	xorl 	$1, \dst
	.endm

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
instr_begin: .int 0

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
	movl 	%edi, instr_begin

# Moving stack address to %esi
# %esi now plays a role of stack pointer
	movl	$stack, %esi

entry:
	xorl	%eax, %eax
	BYTE	%al
	movb	%al,%ah
	andb    $15,%al
	andb    $240,%ah
	shrb 	$4,%ah
	movsx   %ah,%ebx
	movl    high(,%ebx,0x4),%ebx
	call    *%ebx

# Restoring callee's frame pointer
	popl	%ebp

# Returning
	ret
high: .int binop,trivial,0,0,0,0,0,0

binop:
    movsx   %al,%ebx
    movl    binops-0x4(,%ebx,0x4),%ebx
    jmp     *%ebx
binops:	.int b_add,b_sub,b_mul,b_div,b_mod,b_eq,b_neq,b_lt,b_le,b_gt,b_ge,b_and,b_or

trivial:
    movsx   %al,%ebx
    movl    trivials-0x4(,%ebx,0x4),%ebx
    jmp     *%ebx
trivials: .int bc_const,0,bc_sexp,bc_sti,bc_sta,bc_jmp,bc_end,bc_ret,bc_drop,bc_dup,0,bc_elem


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


/* some trivial binops */

bc_drop:
	POP %eax
	ret

bc_dup:
	POP 	%eax
	PUSH	%eax
	PUSH	%eax
	ret

bc_sti:
	ret

bc_jmp:
	ret

bc_end:
	ret

bc_ret:
	ret

bc_elem:
	ret

bc_sexp:
	ret

bc_const:
	WORD %ecx
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
	WORD %ecx
	movl	global_data(, %ecx, 4), %eax
	PUSH	%eax
	ret

bc_ldl:
	WORD %ecx
	negl	%ecx
	movl	-4(%ebp, %ecx, 4), %eax
	PUSH	%eax
	ret

bc_lda:
	WORD %ecx
	/*  Maybe it should be 8, not 4 (resolve on merging vs Call)  */
	movl	4(%ebp, %ecx, 4), %eax
	PUSH	%eax
	ret

bc_stg:
	WORD %ecx
	POP		%eax
	movl	%eax, global_data(, %ecx, 4)
	ret

bc_stl:
	WORD %ecx
	negl	%ecx
	POP		%eax
	movl	%eax, -4(%ebp, %ecx, 4)
	ret

bc_sta:
	WORD %ecx
	POP		%eax
	/*  Maybe it should be 8, not 4 (resolve on merging vs Call)  */
	movl	%eax, 4(%ebp, %ecx, 4)
	ret

bc_array:
	WORD 	%ecx
	movl	%ecx, %edx
	test	%edx, %edx
	jz 		push_loop_end
push_loop_begin:
	POP		%ebx
	pushl	%ebx
	decl	%edx
	jnz		push_loop_begin
push_loop_end:
	FIX_BOX	%ecx
	pushl 	%ecx
	call	Barray
	popl	%ecx
	FIX_UNB	%ecx
	movl	%ecx, %edx
	test	%edx, %edx
	jz 		pop_loop_end
pop_loop_begin:
	popl	%ebx
	decl	%edx
	jnz		pop_loop_begin
pop_loop_end:
	PUSH	%eax
	ret

bc_elem:
# store arguments {
	POP		%ebx
	pushl	%ebx
	POP		%ebx
	pushl	%ebx
# }
	call	Belem
# pop arguments {
	popl	%ebx
	popl	%ebx
# }
	PUSH 	%eax
	ret

	.data
scanline: .asciz "something bad happened"
global_data: .skip 4 * 1000
