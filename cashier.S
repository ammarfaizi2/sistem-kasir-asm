
/**
 * @author Ammar Faizi <ammarfaizi2@gmail.com> https://www.facebook.com/ammarfaizi2
 * @version 0.0.1
 * @license GNU GPLv2
 */

/**


	struct product {
		uint64_t	id;
		uint64_t	price;
		char		name[64];
	};

**/

#include "const.S"
#include <errno.h>

#ifndef ALIGN_TRAP
#define ALIGN_TRAP movdqa (%rsp), %xmm0
#endif

.section .rodata
.align 8
welcome_str:
	.byte 0x1b
	.byte 0x63
	.ascii "-------------------------------------------------------------\n"
	.ascii "\t--- Welcome to Cashier System Application ---\n"
	.ascii "-------------------------------------------------------------\n"
	.ascii "--- Select Menu ---\n"
	.ascii "\t1. List product\n"
	.ascii "\t2. Add product\n"
	.ascii "\t3. Remove product\n"
	.ascii "\t4. Exit program\n"
	.ascii "Enter option: "
	.byte 0x0

list_product_str:
	.byte 0x1b
	.byte 0x63
	.ascii "-------------------------------------------------------------\n"
	.ascii "\t--- Product List ---\n"
	.ascii "-------------------------------------------------------------\n"
	.byte 0x0

list_open_db_error:
	.ascii "\tCannot open database file!\n"
	.ascii "\tPress enter to continue...\n"
	.byte 0x0

invalid_menu_str:
	.byte 0x1b
	.byte 0x63
	.ascii "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
	.ascii "\tYou entered invalid menu!\n"
	.ascii "\tPlease enter the valid menu!\n"
	.ascii "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
	.ascii "\n\tPress enter to continue...\n\n"
	.byte 0x0

exit_str:
	.ascii "\nClosing program...\n"
	.byte  0x0

database_file:
	.ascii "database.dat"
	.byte 0x0


.align 8
	.quad 0x0
menu_jmp_table:
	.quad list_product
	.quad 0x0
	.quad 0x0
	.quad 0x0
end_menu_jmp_table:
	.quad 0x0

#define NUM_OF_MENU ((end_menu_jmp_table - menu_jmp_table)/8)


.section .text
.global	_start

_start:
		andq	$~0xf, %rsp
		ALIGN_TRAP
		xorl	%ebp, %ebp
		callq	main

		# sys_exit
		movl	%eax, %edi
		movl	$0x3c, %eax
		syscall


# int main(void);
main:
		pushq	%rbp
		movq	%rsp, %rbp
		ALIGN_TRAP

	._Lmain_show_menu:
		callq	main_menu
		cmpl	$0x1, %eax
		jb	._Lmain_invalid_menu
		cmpl	$NUM_OF_MENU, %eax
		ja	._Lmain_invalid_menu
		leaq	menu_jmp_table(%rip), %rdi
		leaq	-0x8(%rdi, %rax, 0x8), %rdi
		cmpq	$0x0, (%rdi)
		je	._Lmain_out
		callq	*(%rdi)
		jmp	._Lmain_show_menu

	._Lmain_invalid_menu:
		leaq	invalid_menu_str(%rip), %rdi
		callq	my_print
		callq	hold_screen
		jmp	._Lmain_show_menu

	._Lmain_out:
		leaq	exit_str(%rip), %rdi
		callq	my_print
		xorl	%eax, %eax
		popq	%rbp
		ret

# int main_menu(void);
main_menu:
		pushq	%rbp
		movq	%rsp, %rbp
		subq	$0x10, %rsp
		ALIGN_TRAP

		leaq	welcome_str(%rip), %rdi
		callq	my_print

		movq	%rsp, %rdi
		movl	$0x10, %esi
		callq	my_input

		movq	%rsp, %rdi
		callq	my_atoi

		mov	%rbp, %rsp
		pop	%rbp
		ret


# void list_product(void);
list_product:
		pushq	%rbp
		movq	%rsp, %rbp
		ALIGN_TRAP


		leaq	list_product_str(%rip), %rdi
		callq	my_print


		# sys_open
		movl	$0x2, %eax
		leaq	database_file(%rip), %rdi
		movl	$O_RDONLY, %esi
		syscall
		testl	%eax, %eax
		js	._Llist_product_error

		jmp	._Llist_product_out
	._Llist_product_error:
		leaq	list_open_db_error(%rip), %rdi
		callq	my_print
	._Llist_product_out:
		callq	hold_screen
		popq	%rbp
		ret

# unsigned int my_atoi(const char *rdi);
my_atoi:
		pushq	%rbp
		movq	%rsp, %rbp
		ALIGN_TRAP
		xorl	%ecx, %ecx
		xorl	%esi, %esi
		xorl	%r9d, %r9d
	._Lmy_atoi_loop_chk:
		cmpb	$0x30, (%rdi, %rcx)
		jb	._Lmy_atoi_convert
		cmpb	$0x39, (%rdi, %rcx)
		ja	._Lmy_atoi_convert
		incl	%ecx
		jmp	._Lmy_atoi_loop_chk
	._Lmy_atoi_convert:
		testl	%ecx, %ecx
		jz	._Lmy_atoi_out
		movzbl	-0x1(%rdi, %rcx), %esi
		subl	$0x30, %esi
		addq	%rsi, %r9
		decl	%ecx
		jz	._Lmy_atoi_out

		movl	$0xa, %eax
		movl	%eax, %r10d
	._Lmy_atoi_exp:
		decl	%ecx
		testl	%ecx, %ecx
		jz	._Lmy_atoi_div
		xorl	%edx, %edx
		mulq	%r10
		jmp	._Lmy_atoi_exp

	._Lmy_atoi_div:
		cmpq	$1, %rax
		je	._Lmy_atoi_out

		movq	%rax, %rcx
		movzbl	(%rdi), %esi
		subl	$0x30, %esi

		xorl	%edx, %edx
		mulq	%rsi
		addq	%rax, %r9
		movq	%rcx, %rax

		xorl	%edx, %edx
		divq	%r10

		incq	%rdi
		jmp	._Lmy_atoi_div
	._Lmy_atoi_out:
		movq	%r9, %rax
		popq	%rbp
		ret



# size_t strlen(const char *rdi);
my_strlen:
		pushq	%rbp
		movq	%rsp, %rbp
		ALIGN_TRAP
		xorl	%eax, %eax
	._Lmy_strlen_loop:
		cmpb	$0, (%rdi, %rax)
		jz	._Lmy_strlen_out
		incq	%rax
		jmp	._Lmy_strlen_loop
	._Lmy_strlen_out:
		popq	%rbp
		ret


# size_t my_print(const char *rdi);
my_print:
		pushq	%rbx
		pushq	%rbp
		movq	%rsp, %rbp
		pushq	%rax
		ALIGN_TRAP
		movq	%rdi, %rbx
		callq	my_strlen

		# sys_write
		movq	%rax, %rdx
		movl	$0x1, %eax
		movl	%eax, %edi
		movq	%rbx, %rsi
		syscall

		movq	%rbp, %rsp
		popq	%rbp
		pop	%rbx
		ret

# size_t my_input(char *rdi, size_t rsi);
my_input:
		pushq	%r12
		pushq	%rbx
		pushq	%rbp
		movq	%rsp, %rbp
		subq	$((0x400 + 0xf) & ~0xf), %rsp
		ALIGN_TRAP
		movq	%rdi, %rbx
		movq	%rsi, %r12

		# sys_write
		xorl	%eax, %eax
		movl	$0x1, %edi
		movl	$0x400, %edx
		movq	%rsp, %rsi
		syscall

		cmpb	$0xa, -0x1(%rsp, %rax)
		jne	._Lmy_input_memcpy
		dec	%rax
		movb	$0x0, (%rsp, %rax)
	._Lmy_input_memcpy:
		movl	%eax, %ecx
		cmpq	%rax, %r12
		cmovb	%r12, %rcx
		movq	%rbx, %rdi
		movq	%rsp, %rsi
		rep	movsb
		movb	$0x0, -0x1(%rbx, %r12)

		movq	%rbp, %rsp
		popq	%rbp
		popq	%rbx
		popq	%r12
		ret


hold_screen:
		pushq	%rbp
		movq	%rsp, %rbp
		subq	$0x10, %rsp
		ALIGN_TRAP
		movq	%rsp, %rdi
		movl	$0x10, %esi
		callq	my_input
		movq	%rbp, %rsp
		popq	%rbp
		ret
