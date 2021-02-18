
;
; @author Ammar Faizi <ammarfaizi2@gmail.com> https://www.facebook.com/ammarfaizi2
; @version 0.0.1
; @license GNU GPLv2
;

;
;  struct product {
;	uint64_t	id;
;	uint64_t	price;
;	char		name[64];
;  };
;

%define	SIZE_PRODUCT			(8 + 8 + 64)
%define OFF_PRODUCT_ID_BARANG		(0)
%define OFF_PRODUCT_HARGA_BARANG	(8)
%define OFF_PRODUCT_NAMA_BARANG		(16)

[bits 64]

section	.rodata
align	16
welcome_str:
	db 0x1b, 0x63
	db 9,"--- Welcome to Cashier System Application ---",10



section	.text
global _start

align	8
_start:
		; Make sure stack is 16-byte aligned.
		and	rsp, ~0xf
		xor	ebp, ebp
		call	main

		; sys_exit
		mov	edi, eax
		mov	eax, 60
		syscall


align	8
; int main(void);
main:
		push	rbp
		mov	rbp, rsp

		call	menu

		xor	eax, eax
		pop	rbp
		ret


align	8
; int menu(const char *rdi);
menu:
		push	rbp
		mov	rbp, rsp


		pop	rbp
		ret


align	8
; size_t my_strlen(const char *rdi);
my_strlen:
		push	rbp
		mov	rbp, rsp
		xor	eax, eax
align 16, nop	qword [rax + rax]
	._loop:
		cmp	byte [rdi + rax], 0
		je	._out
		inc	rax
		jmp	._loop
align 16, nop	qword [rax + rax]
	._out:
		pop	rbp
		ret

align	8
; size_t my_print(const char *rdi);
my_print:
		push	rbx
		push	rbp
		mov	rbp, rsp
		sub	rsp, 8

		mov	rbx, rdi
		call	my_strlen

		; sys_write
		mov	rdx, rax
		mov	eax, 1
		mov	edi, eax
		mov	rsi, rbx
		syscall

		mov	rsp, rbp
		pop	rbp
		pop	rbx
		ret
