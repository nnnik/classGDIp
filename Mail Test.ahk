#Include classGDIp.ahk
#NoTrayIcon
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

testBrush    := new GDIp.Brush.LinearGradientBrush( [ 0, 0 ], [ 0, 0, size.1 / 2, size.2 / 2 ], 0, 1 )
testPen      := new GDIp.Pen( testBrush, 5 )
testPen2     := new GDIp.Pen( 0xFF000000, 10 )
GoTo,Paint

F5::
Paint:
Critical
testBrush.setColor( color := [ randomColor(), randomColor() ] )
testPen.setBrush( testBrush )
testPen2.setColor( color.1 )
testGraphics.clear( 0xFF000000 )
testGraphics.drawLines( testPen , [ [ 0, 0 ],[ size.1 / 2 ,size.2 / 2 ], [ size.1, 0 ] ] )
testGraphics.drawLines( testPen2, [ [ 0, 0 ], [ size.1, 0 ], [ size.1, size.2 ], [ 0, size.2 ], [ 0, 0 ] ] )
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