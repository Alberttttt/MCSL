	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	student_id: .byte 0, 4, 1, 0, 0, 0, 1 //TODO: put your student id here

.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_BASE, 0x48000000
	.equ GPIO_BSRR_OFFSET, 0x18
	.equ GPIO_BRR_OFFSET, 0x28
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_ODR, 0x48000014
	.equ DECODE_MODE,	0x09
	.equ SHUTDOWN,	0x0C
	.equ INTENSITY,	0x0A
	.equ SCAN_LIMIT, 0x0B
	.equ DISPLAY_TEST, 0x0F
	.equ DATA, 0x20 //PA5
	.equ LOAD, 0x40 //PA6
	.equ CLOCK, 0x80 //PA7

main:
    BL   GPIO_init
    BL   max7219_init
    //TODO: display your student id on 7-Seg LED
    ldr r9, = student_id
    ldr r2, =#0
    ldr r3, =#8
    ldr r4, =#9
.for_loop:
	ldrb r1, [r9,r2]
	add r0, r2, #1
	sub r0, r3, r0
	BL MAX7219Send
	add r2, r2, #1
	cmp r2, r3
	bne .for_loop
Program_end:
	B Program_end

GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
	movs 	r0, #0x1
	ldr		r1, =RCC_AHB2ENR
	str		r0,[r1]

	movs	r0, #0x5400
	ldr  	r1, =GPIOA_MODER
	ldr		r2, [r1]
	and		r2, #0xFFFF03FF
	orrs	r2,r2,r0
	str		r2,[r1]

	movs	r0, #0xA800
	ldr		r1, =GPIOA_OSPEEDR
	strh	r0,[r1]

	ldr		r1, =GPIOA_ODR

	BX LR

MAX7219Send:
   //input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, lr}
	lsl r0, r0, #8
	add r0, r0, r1
	ldr r1, =#GPIOA_BASE
	ldr r2, =#LOAD
	ldr r3, =#DATA
	ldr r4, =#CLOCK
	ldr r5, =#GPIO_BSRR_OFFSET
	ldr r6, =#GPIO_BRR_OFFSET
	mov r7, #16//r7 = i
.max7219send_loop:
	mov r8, #1
	sub r9, r7, #1
	lsl r8, r8, r9 // r8 = mask
	str r4, [r1,r6] //HAL_GPIO_WritePin(GPIOA, CLOCK, 0);
	tst r0, r8
	beq .bit_not_set //bit not set
	str r3, [r1,r5]
	b .if_done
.bit_not_set:
	str r3, [r1,r6]
.if_done:
	str r4, [r1,r5]
	subs r7, r7, #1
	bgt .max7219send_loop
	str r2, [r1,r6]
	str r2, [r1,r5]
	pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, pc}
	BX LR

max7219_init:
	//TODO: Initial max7219 registers.
	push {r0, r1, r2, lr}
	ldr r0, =#DECODE_MODE
	ldr r1, =#0xFF
	BL MAX7219Send
	ldr r0, =#DISPLAY_TEST
	ldr r1, =#0x0
	BL MAX7219Send
	ldr r0, =#SCAN_LIMIT
	ldr r1, =0x6
	BL MAX7219Send
	ldr r0, =#INTENSITY
	ldr r1, =0xA
	BL MAX7219Send
	ldr r0, =#SHUTDOWN
	ldr r1, =#0x1
	BL MAX7219Send
	pop {r0, r1, r2, pc}
	BX LR