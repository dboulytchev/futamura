# Various macro definitions
# fixnum arithmetics: make box for an integer
	.macro NEXT_ITER
	jmp entry_point
	.endm
	.macro TERMINATE
	jmp terminate
	.endm
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

	.macro SWITCH flag table
	movsx   \flag,%ebx
	movl    \table-0x4(,%ebx,0x4),%ebx
	jmp     *%ebx
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
# %edi now plays a role of instruction
# pointer
	movl	8(%esp), %edi
	movl 	%edi, instr_begin

# Moving stack address to %esi
# %esi now plays a role of stack pointer
	movl	$stack, %esi

entry_point:
# Decode next insn
	xorl	%eax, %eax
	BYTE	%al
	movb	%al,%ah
	andb    $15,%al
	andb    $240,%ah
	shrb 	$4,%ah
# Outer switch
	movsx   %ah,%ebx
	movl    high(,%ebx,0x4),%ebx
	jmp    *%ebx

terminate:
# Restoring callee's frame pointer
	popl	%ebp

# Returning
	ret
high: .int binop,trivial,ld,0,st,cond_jump,0,0

binop:
	SWITCH %al binops
binops:	.int b_add,b_sub,b_mul,b_div,b_mod,b_eq,b_neq,b_lt,b_le,b_gt,b_ge,b_and,b_or

trivial:
	SWITCH %al trivials
trivials: .int bc_const,0,bc_sexp,bc_sti,0,bc_jmp,bc_end,0,bc_drop,bc_dup,0,bc_elem

st:
	SWITCH %al sts
sts: .int bc_st_g,bc_st_l,bc_st_a

ld:
	SWITCH %al lds
lds: .int bc_ld_g,bc_ld_l,bc_ld_a

cond_jump:
	SWITCH %al cond_jumps
cond_jumps: .int bc_cjmpz,bc_cjmpnz,0,0,0,0,0,0,0,0,0


b_add:	POP2 	%eax %ebx
	FIX_UNB %eax
	FIX_UNB %ebx
	addl	%ebx, %eax
	FIX_BOX %eax
	PUSH	%eax
	NEXT_ITER

b_sub:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB %ebx
	subl	%eax, %ebx
	FIX_BOX %ebx
	PUSH	%ebx
	NEXT_ITER

b_mul:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB %ebx
	imul	%ebx
	FIX_BOX %eax
	PUSH	%eax
	NEXT_ITER

b_div:	POP2	%ebx %eax
	FIX_UNB %eax
	FIX_UNB %ebx
	cltd
	idiv	%ebx
	FIX_BOX %eax
	PUSH	%eax
	NEXT_ITER

b_mod:	POP2	%ebx %eax
	FIX_UNB %eax
	FIX_UNB %ebx
	cltd
	idiv	%ebx
	FIX_BOX %edx
	PUSH	%edx
	NEXT_ITER

b_eq: 	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB %ebx
	xorl	%edx, %edx
	cmpl	%eax, %ebx
	xorl 	%eax, %eax
	seteb	%dl
	FIX_BOX %edx
	PUSH 	%edx
	NEXT_ITER

b_neq: 	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB %ebx
	xorl	%edx, %edx
	cmpl	%eax,%ebx
	setneb	%dl
	FIX_BOX %edx
	PUSH 	%edx
	NEXT_ITER

b_lt: 	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	xorl	%edx, %edx
	cmpl	%eax, %ebx
	setlb	%dl
	FIX_BOX %edx
	PUSH	%edx
	NEXT_ITER

b_le:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	xorl	%edx, %edx
	cmpl	%eax, %ebx
	setleb	%dl
	FIX_BOX %edx
	PUSH	%edx
	NEXT_ITER

b_gt: 	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	xorl	%edx, %edx
	cmpl	%eax, %ebx
	setgb	%dl
	FIX_BOX %edx
	PUSH	%edx
	NEXT_ITER

b_ge:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	xorl	%edx, %edx
	cmpl	%eax, %ebx
	setgeb	%dl
	FIX_BOX %edx
	PUSH	%edx
	NEXT_ITER

b_and:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	andl	%eax, %ebx
	FIX_BOX %ebx
	PUSH	%ebx
	NEXT_ITER

b_or:	POP2	%eax %ebx
	FIX_UNB %eax
	FIX_UNB	%ebx
	orl		%eax, %ebx
	FIX_BOX %ebx
	PUSH	%ebx
	NEXT_ITER


/* some trivial binops */

bc_drop:
	POP %eax
	NEXT_ITER

bc_dup:
	POP 	%eax
	PUSH	%eax
	PUSH	%eax
	NEXT_ITER

bc_sti:
	WORD %ecx
	POP	%eax
	POP	%ecx
	movl %eax, (%ecx)
	NEXT_ITER

bc_sta:
	WORD %ecx
	POP 	%eax
	POP 	%ecx
	POP 	%edx
	push 	%edx
	push 	%ecx
	push 	%eax
	call 	Bsta
	PUSH	%eax
	add		$12, %esp
	NEXT_ITER

bc_end:
	NEXT_ITER

bc_elem:
	NEXT_ITER

bc_sexp:
	NEXT_ITER

bc_const:
	WORD %ecx
	FIX_BOX	%ecx
	PUSH 	%ecx
	NEXT_ITER

bc_line:
	nop
	NEXT_ITER

bc_fail:
	pushl	$scanline
# Runtime call, it terminate all process with 255 code
	call	failure

bc_ld_g:
	WORD %ecx
	movl	global_data(, %ecx, 4), %eax
	PUSH	%eax
	NEXT_ITER

bc_ld_l:
	WORD %ecx
	negl	%ecx
	movl	-4(%ebp, %ecx, 4), %eax
	PUSH	%eax
	NEXT_ITER

bc_ld_a:
	WORD %ecx
	/*  Maybe it should be 8, not 4 (resolve on merging vs Call)  */
	movl	4(%ebp, %ecx, 4), %eax
	PUSH	%eax
	NEXT_ITER

bc_st_g:
	WORD %ecx
	POP		%eax
	movl	%eax, global_data(, %ecx, 4)
	NEXT_ITER

bc_st_l:
	WORD %ecx
	negl	%ecx
	POP		%eax
	movl	%eax, -4(%ebp, %ecx, 4)
	NEXT_ITER

bc_st_a:
	WORD %ecx
	POP		%eax
	/*  Maybe it should be 8, not 4 (resolve on merging vs Call)  */
	movl	%eax, 4(%ebp, %ecx, 4)
	NEXT_ITER

bc_cjmpz:
	WORD %ecx
	POP	%eax
	FIX_UNB	%eax
	addl	instr_begin, %ecx
	testl	%eax, %eax
	je	not_go1
	movl	%ecx, %edi
not_go1:
	NEXT_ITER

bc_cjmpnz:
	WORD %ecx
	POP	%eax
	FIX_UNB	%eax
	addl	instr_begin, %ecx
	testl	%eax, %eax
	jne	not_go2
	movl	%ecx, %edi
not_go2:
	NEXT_ITER

bc_jmp:
	WORD %ecx
	addl	instr_begin, %ecx
	movl	%ecx, %edi
	NEXT_ITER

	.data
scanline: .asciz "something bad happened"
global_data: .skip 4 * 1000
