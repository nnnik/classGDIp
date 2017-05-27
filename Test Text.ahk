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

testFamily       := new GDIp.FontFamily( "Arial" )
testFont         := new GDIp.Font( testFamily, 16 )
testStringFormat := new GDIp.StringFormat()
testBrush        := new GDIp.SolidBrush( 0xFF000000 )
testBrush2       := new GDIp.SolidBrush( 0xFF000000 )

stringRect := testGraphics.measureString( "Hello World!", testFont, rect, testStringFormat ).Rect
stringRect.1 := ( rect.3 / 2 ) - ( stringRect.3 / 2 )
stringRect.2 := ( rect.4 / 2 ) - ( stringRect.4 / 2 )
roundedStringRect := []
For each, val in stringRect
	roundedStringRect[ each ] := Round( val )
GoTo,Paint

F5::
Paint:
Critical
testBrush.setColor( randomColor() )
testBrush2.setColor( randomColor() )
testGraphics.clear( randomColor() )
testGraphics.fillRectangle( testBrush2, roundedStringRect )
testGraphics.drawString( "Hello World!", testFont, stringRect, testStringFormat, testBrush )
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