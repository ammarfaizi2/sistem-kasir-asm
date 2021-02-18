
section .rodata
	menu1	db "----- Selamat Datang di Aplikasi Sistem Kasir! -----",10,0
	menu2	db "Pilih menu:",10,0
	menu3	db 9,"1. List daftar barang",10,0
	menu4	db 9,"2. Tambah barang",10,0
	menu5	db 9,"3. Hapus barang",10,0
	align	8
	m_arr	dq menu1, menu2, menu3, menu4, 0

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
	mov	rbx, m_arr
.f_loop:
	mov	rax, [rbx]
	test	rax, rax
	jz	.f_out
	mov	rdi, rax
	call	my_print
	add	rbx, 8
	jmp	.f_loop
.f_out:
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
