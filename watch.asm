org 0x6000
use16

mov ax,0x0003
int 0x10
mov ax,0x0500
int 10h
mov ch,0x20
mov ah,0x01
int 0x10
watch:
mov byte [color],0x31
call getpos
mov dx,0x0301
call setpos
call time
call space
call newline
call space
call date
call space
call newline
call space
call timer
mov ax,0x0E20
int 0x10
int 0x10

xor ah,ah
int 0x1a

mov bx,cx
;mov bx,0x0F38
;add bl,dl
;sub bl,dh
;add bh,bl
push bx
push dx
call line
call delay
mov byte [color],0x00
pop dx
pop bx
call line

mov ah,0x01
int 0x16
jz watch
mov dx,0x0a00
call setpos
mov cx,0x0506
mov ah,0x01
int 0x10
xor bx,bx
mov es,bx
ret

printf:
pusha
mov ah,0x0E
int 0x10
popa
ret

printc:
;mov al,0x20
;printf:
pusha
xor bh,bh
mov ax,0x0920
mov bl,[color]
mov cx,0x0001
int 0x10
;call getpos
;inc dl
;call setpos
popa
ret

colon:
mov al,':'
call printf
ret

space:
mov al,' '
call printf
ret

printh:
push ax
shr al,4
cmp al,10
sbb al,69h
das
call printf
pop ax
ror al,4
shr al,4
cmp al,10
sbb al,69h
das
call printf
ret

newline:
mov al,0x0D
call printf
mov al,0x0A
call printf
ret

date:
mov ah,0x04
int 0x1a
mov al,dl
call printh
call colon
mov al,dh
call printh
call colon
mov al,ch
call printh
;call colon
mov al,cl
call printh
ret

time:
mov ah,0x02
int 0x1a
mov al,ch
call printh
call colon
mov al,cl
call printh
call colon
mov al,dh
call printh
ret

timer:
;mov ah,0x00
xor ah,ah
int 0x1a
mov al,ch
call printh
call colon
mov al,cl
call printh
call colon
mov al,dh
call printh
call colon
mov al,dl
call printh
ret

getpos:
mov ah,0x03
xor bh,bh
int 10h
ret

setpos:

mov ah,0x02
xor bh,bh

int 10h
ret

delay:
xor ah,ah
int 1ah
mov [x],dl
.delay_loop:
xor ah,ah
int 1ah
cmp [x],dl
je .delay_loop
ret

line:
cmp bh,dh
jle .x_fine
xchg bh,dh
.x_fine:
cmp bl,dl
jle .y_fine
xchg bl,dl
.y_fine:
mov [x],bh
mov [y],bl
;mov [x1],bh
;mov [y1],bl
mov [x2],dh
mov [y2],dl
mov byte [eps],0
sub dh,bh
mov [wx],dh
sub dl,bl
mov [wy],dl
.loop:
mov dl,[x]
mov dh,[y]
call setpos
;mov al,0x20
call printc
;call getpos
;dec dl
;call setpos
mov dl,[wy]
add [eps],dl
mov dl,[eps]

shl dl,1
mov dh,[wx]
cmp dl,dh
jl .skip
sub dl,dh
mov [eps],dl
inc byte [y]
.skip:
inc byte [x]
mov dl,[x2]
cmp [x],dl
jl .loop

dec byte [x]
dec byte [y]
mov dl,[y2]
cmp [y],dl
jl .y_axis
ret
.y_axis:
inc byte [y]
mov dl,[x]
mov dh,[y]
call setpos
call printc
mov dl,[y2]
cmp [y],dl
jl .y_axis
ret

x:
db 0x00
y:
db 0x00
;x1:
;db 0x00
;y1:
;db 0x00
x2:
db 0x00
y2:
db 0x00
wx:
db 0x00
wy:
db 0x00
eps:
db 0x00
color:
db 0x31

times 512-($-$$) db 0x90