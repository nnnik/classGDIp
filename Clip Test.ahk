#Include classGDIp.ahk
#NoTrayIcon
API := new GDIp()

size         := [ 1000, 600 ]
rect         := size.clone(), rect.insertAt( 1, 0, 0 )
rect2        := rect.clone(), rect2.1 += 100, rect2.2 += 100, rect2.3 -= 200, rect2.4 -= 200

GUI, new
GUI, +hwndGUI1 -Caption +ToolWindow
Gui,Show,% "w" . size.1 . " h" . size.2
SetFormat ,IntegerFast ,H

hDC          := new GDI.DC( GUI1 )
testGraphics := hDC.getGraphics()
GoTo,Paint

F5::
Paint:
Critical
testGraphics.setClipRect( rect )
testGraphics.setClipRect( rect2, 3 )
testGraphics.clear( 0xFF00FF00 )
testGraphics.setClipRect( rect, 3 )
testGraphics.clear( 0xFFFF00FF )
testGraphics.resetClip()
return

~LButton::
If WinActive( "ahk_id " . GUI1 )
	GoTo, Paint
esc::
GUIClose:
ExitApp

randomColor( A := 255 )
{
	if ( A == "" )
		Random,A,0,255
	Random,R,0,255
	Random,G,0,255
	Random,B,0,255
	return ( A << 24 ) | ( R << 16 ) | ( G << 8 ) | B 
}