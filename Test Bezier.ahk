#Include classGDIp.ahk
;#NoTrayIcon
API := new GDIp()

size         := [ 1000, 600 ]
rect         := size.clone(), rect.insertAt( 1, 0, 0 )

GUI, new
GUI, +hwndGUI1 -Caption +ToolWindow
Gui,Show,% "w" . size.1 . " h" . size.2
SetFormat ,IntegerFast ,H

hDC          := new GDI.DC( GUI1 )
testGraphics := hDC.getGraphics()
testGraphics.setSmoothingMode( 4 )
testGraphics.setInterpolationMode( 7 )

testPen       := new GDIp.Pen( 0xFF000000, 4 )
Bezier        := [ [ 0, 0], [ 1000, 0 ], [ 0, 600 ], [ 1000, 600 ], [ 1000, 0 ], [ 0, 600 ], [ 0, 0 ] ] 
GoTo,Paint

F5::
Paint:
Critical
testGraphics.clear( randomColor() )
testPen.setColor( randomColor() )
testGraphics.drawBezier( testPen, Bezier )
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