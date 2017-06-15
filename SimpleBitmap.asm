.386
.model flat,stdcall
option casemap:none
include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\gdi32.inc
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\gdi32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
;#define IDB_MAIN 1
;IDB_MAIN BITMAP "tweety78.bmp"
IDB_MAIN   equ 1

.data
ClassName db "SimpleWin32ASMBitmapClass",0
AppName  db "Win32ASM Simple Bitmap Example",0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
hBitmap dd ?
copy HDC ?
x dw ?
y dw ?
pen HPEN ?
desk dd ?
dc dd ?
bgr HDC ?
gr HDC ?
.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke GetCommandLine
	mov    CommandLine,eax
	invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInstance
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_WINDOW+1
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
           hInst,NULL
	mov   hwnd,eax
	invoke ShowWindow, hwnd,SW_SHOWNORMAL
	invoke UpdateWindow, hwnd
	.while TRUE
		invoke GetMessage, ADDR msg,NULL,0,0
		.break .if (!eax)
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
	.endw
	mov     eax,msg.wParam
	ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
   LOCAL ps:PAINTSTRUCT
   LOCAL hdc:HDC
   LOCAL hMemDC:HDC
   LOCAL rect:RECT
   .if uMsg==WM_CREATE
      invoke LoadBitmap,hInstance,IDB_MAIN
      mov hBitmap,eax
	  invoke CreatePen,PS_SOLID,2,12
	  mov pen,eax
	  invoke CreateBitmap,1000,1000,1000,24,NULL
	  invoke LoadBitmap,hInstance,eax
	  mov copy,eax
	  invoke CreateCompatibleDC,hdc
      mov hMemDC,eax
      invoke SelectObject,hMemDC,hBitmap
      invoke BitBlt,copy,0,0,1000,1000,hMemDC,0,0,SRCCOPY
      invoke DeleteDC,hMemDC
	  
   .elseif uMsg==WM_PAINT
      invoke BeginPaint,hWnd,addr ps
      mov hdc,eax
	  mov gr,eax
      
      invoke CreateCompatibleDC,hdc
      mov hMemDC,eax
      invoke SelectObject,hMemDC,copy
	  invoke GetClientRect,hWnd,addr rect
      invoke BitBlt,hdc,0,0,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
      invoke DeleteDC,hMemDC
      invoke EndPaint,hWnd,addr ps
	  ;invoke BeginPaint ,hBitmap,addr ps
	  ;invoke SetPixel,hBitmap,x,y,12
	  
		invoke EndPaint,hBitmap,addr ps
	.elseif uMsg==WM_MOUSEMOVE
		mov eax,lParam
		mov x,ax
		shr eax,16
		mov y,ax
		;invoke GetDesktopWindow
		;mov desk,eax
		;invoke GetDC,desk
		;mov dc,eax
		;invoke BeginPaint ,hWnd,addr ps
		;invoke GetClientRect,hWnd,addr ps
		;mov hdc,eax
		;invoke SetMapMode,hdc,MM_ANISOTROPIC
		
		invoke MoveToEx ,gr,0,0,NULL
		invoke SelectObject ,gr,pen 
		invoke LineTo ,gr,x,y
		;invoke SendMessage,hWnd,WM_ERASEBKGND,bgr,0
		;invoke InvalidateRect,hWnd,NULL,FALSE
	;.elseif uMsg==WM_ERASEBKGND
	;	mov eax,wParam
	;	mov bgr,eax
	;	invoke GetClientRect,hWnd,addr ps
	;	invoke SetMapMode,bgr,MM_ANISOTROPIC
	;	invoke SetWindowExtEx,bgr,100,100,NULL
	;	invoke SetViewportExtEx,bgr,1000,1000,NULL
		;invoke FillRect,bgr,addr ps,12
	;	invoke MoveToEx ,bgr,0,0,NULL
	;	invoke SelectObject ,bgr,pen 
	;	invoke LineTo ,bgr,x,y
	.elseif uMsg==WM_DESTROY
      invoke DeleteObject,hBitmap
		invoke PostQuitMessage,NULL
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam		
		ret
	.ENDIF
	xor eax,eax
	ret
WndProc endp
end start
