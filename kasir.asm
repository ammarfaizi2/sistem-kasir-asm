
;
; @author Ammar Faizi <ammarfaizi2@gmail.com> https://www.facebook.com/ammarfaizi2
; @version 0.0.1
; @license GNU GPLv2
;

;

;  struct data_barang {
;	uint64_t	id_barang;
;	uint64_t	harga_barang;
;	char		nama_barang[64];
;  };
;

[bits 64]

section .rodata
align	8
menu_str:
	db 0x1b, 0x63
	db "----- Selamat Datang di Aplikasi Sistem Kasir! -----",10
	db "--- [Menu] ---",10
	db 9,"1. List daftar barang",10
	db 9,"2. Tambah barang",10
	db 9,"3. Hapus barang",10
	db 9,"4. Tutup aplikasi",10
	db "Masukkan pilihan: ",0

align	8
invalid_menu_num_str:
	db 0x1b, 0x63
	db "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",10
	db 9,"Menu yang Anda masukkan tidak valid!",10
	db 9,"Silakan masukkan ulang pilihan Anda...",10,10
	db 9,"Tekan enter untuk melanjutkan...",10
	db "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",10,0


align	8
daftar_barang_str:
	db 0x1b, 0x63
	db "----------------------------------------------------",10
	db 9,"[ Menu Daftar Barang ]",10,0
daftar_barang_kosong_str:
	db 10,10,"Daftar barang masih kosong.",10,10,10
	db "----------------------------------------------------",10,0


align	8
tutup_aplikasi_str:
	db 10,"Aplikasi ditutup...",10,0


align	8
tambah_barang_str:
	db 0x1b, 0x63
	db "----------------------------------------------------",10
	db 9,"--- Masukkan data barang yang hendak ditambahkan ---",10,0
tambah_nama_barang_str:
	db "Nama Barang (maks 64 karakter): ",0
tambah_harga_barang_str:
	db "Harga Barang: ",0
tambah_jumlah_stok_barang_str:
	db "Jumlah Stok Barang: ",0


align	8
file_database_barang:
	db "database_barang.dat",0


align	8
menu_jump_table:
	dq	menu_list_daftar_barang
	dq	menu_tambah_barang
	dq	0
	dq	-1
	dq	0


section .text
global _start

_start:
	and	rsp, ~0xf
	xor	ebp, ebp
	call	main
	mov	edi, eax
	mov	eax, 60
	syscall

main:
	push	rbp
	mov	rbp, rsp
	call	menu
	mov	rsp, rbp
	pop	rbp
	ret


menu:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 16

.show_menu:
	lea	rdi, [rel menu_str]
	call	my_print
	call	my_input_num
	cmp	eax, 1
	jb	.invalid_menu_num
	cmp	eax, 4
	ja	.invalid_menu_num
	lea	rdi, [rel menu_jump_table]
	lea	rdi, [rdi + rax * 8 - 8]

	cmp	qword [rdi], -1
	je	.f_out

	call	[rdi]
	jmp	.show_menu
.invalid_menu_num:
	lea	rdi, [rel invalid_menu_num_str]
	call	my_print
	call	hold_screen
	jmp	.show_menu

.f_out:
	lea	rdi, [rel tutup_aplikasi_str]
	call	my_print
	xor	eax, eax
	mov	rsp, rbp
	pop	rbp
	ret

menu_list_daftar_barang:
	push	rbp
	mov	rbp, rsp
	lea	rdi, [rel daftar_barang_str]
	call	my_print

	mov	eax, 21
	lea	rdi, [rel file_database_barang]
	mov	esi, 0b100100100
	syscall
	test	rax, rax
	jnz	.db_file_no_access


	jmp	.f_out
.db_file_no_access:
	lea	rdi, [rel daftar_barang_kosong_str]
	call	my_print

.f_out:
	call	hold_screen
	mov	rsp, rbp
	pop	rbp
	ret


menu_tambah_barang:
	push	rbp
	mov	rbp, rsp

	lea	rdi, [rel tambah_barang_str]
	call	my_print

	lea	rdi, [rel tambah_nama_barang_str]
	call	my_print

	lea	rdi, [rel tambah_harga_barang_str]
	call	my_print

	lea	rdi, [rel tambah_jumlah_stok_barang_str]
	call	my_print



	call	hold_screen
	mov	rsp, rbp
	pop	rbp
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

hold_screen:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 16
	mov	rdi, rsp
	mov	esi, 16
	call	my_input
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
	xor	eax, eax
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
