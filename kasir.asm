
[bits 64]

section .data
	menu1	db "----- Selamat Datang di Aplikasi Sistem Kasir! -----",10,0
	menu2	db "--- [Menu] ---",10,0
	menu3	db 9,"1. List daftar barang",10,0
	menu4	db 9,"2. Tambah barang",10,0
	menu5	db 9,"3. Hapus barang",10,0
	menu6	db "Masukkan pilihan: ",0
	align	8
	m_arr	dq menu1, menu2, menu3, menu4, menu5, menu6, 0

section .text
global _start

_start:
	and	rsp, -16
	xor	ebp, ebp
	call	main
	mov	edi, eax
	mov	eax, 60
	syscall

main:
	push	rbp
	mov	rbp, rsp
	call	menu
	xor	eax, eax
	mov	rsp, rbp
	pop	rbp
	ret


menu:
	push	rbx
	push	rbp
	mov	rbp, rsp
	sub	rsp, 16
	lea	rbx, [rel m_arr]
.f_loop:
	mov	rax, [rbx]
	test	rax, rax
	jz	.f_out
	mov	rdi, rax
	call	my_print
	add	rbx, 8
	jmp	.f_loop
.f_out:
	call	my_input_num
	mov	rsp, rbp
	pop	rbp
	pop	rbx
	ret


my_strlen:
	push	rbp
	mov	rbp, rsp
	xor	eax, eax
.f_loop:
	cmp	byte [rdi + rax], 0
	je	 .f_out
	inc	rax
	jmp	.f_loop
.f_out:
	pop	rbp
	ret


my_print:
	push	rbx
	push	rbp
	mov	rbp, rsp

	mov	rbx, rdi
	call	my_strlen

	mov	rdx, rax
	mov	rsi, rbx
	mov	edi, 1
	call	sys_write

	pop	rbp
	pop	rbx
	ret


my_input_num:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 24

	lea	rdi, [rbp - 24]
	mov	esi, 16
	call	my_input

	lea	rdi, [rbp - 24]
	call	my_atoi

	mov	rsp, rbp
	pop	rbp
	ret

my_atoi:
	push	rbp
	mov	rbp, rsp
	xor	ecx, ecx
	mov	eax, ecx
	xor	r9d, r9d
; Traverse the number from the head.
.traverse:
	mov	sil, [rdi + rcx]
	cmp	sil, '0'
	jb	.convert
	cmp	sil, '9'
	ja	.convert
	inc	rcx
	jmp	.traverse
.convert:
	test	ecx, ecx
	jz	.f_out

	dec	ecx
	movzx	edx, byte [rdi + rcx]
	sub	edx, 48
	add	r9d, edx
.convert_loop:
	test	ecx, ecx
	jz	.f_out

	mov	rax, 10
	lea	r10, [rcx - 1]
.convert_exp:
	test	r10, r10
	jz	.convert_rest_byte
	dec	r10
	imul	rax, 10
	jmp	.convert_exp

.convert_rest_byte:
	mov	r10d, 10
.convert_loop_byte:
	movzx	edx, byte [rdi]
	sub	edx, 48
	mov	rsi, rax
	imul	rax, rdx
	add	r9, rax
	mov	rax, rsi

	xor	edx, edx
	div	r10d

	inc	rdi
	dec	rcx
	jnz	.convert_loop_byte
.f_out:
	mov	rax, r9
	mov	rsp, rbp
	pop	rbp
	ret


my_input:
	push	rbx
	push	r12
	push	rbp
	mov	rbp, rsp
	sub	rsp, 1024

	mov	rbx, rdi
	mov	r12, rsi

	xor	eax, eax
	mov	ecx, 1024
	lea	rdi, [rbp - 1024]
	rep	stosb

	xor	edi, edi
	lea	rsi, [rbp - 1024]
	mov	edx, 1024
	call	sys_read

	cmp	byte [rbp - 1024 + rax - 1], 10
	jne	.my_input_memcpy
	mov	byte [rbp - 1024 + rax - 1], 0

.my_input_memcpy:
	cld

	mov	rcx, r12
	cmp	rax, r12
	cmovb	rcx, rax

	lea	rsi, [rbp - 1024]
	mov	rdi, rbx
	rep	movsb

	mov	byte [rbx + r12 - 1], 0
	mov	rsp, rbp
	pop	rbp
	pop	r12
	pop	rbx
	ret


sys_open:
	push	rbp
	mov	rbp, rsp
	mov	eax, 2
	syscall
	pop	rbp
	ret

sys_read:
	push	rbp
	mov	rbp, rsp
	mov	eax, 0
	syscall
	pop	rbp
	ret

sys_write:
	push	rbp
	mov	rbp, rsp
	mov	eax, 1
	syscall
	pop	rbp
	ret
