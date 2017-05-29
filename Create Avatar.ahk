#Include %A_LineFile%/../classGDIp.ahk

Gate   := new GDIp()

avatar := new GDIp.Bitmap( [100, 100] )
canvas := avatar.getGraphics()
canvas.setSmoothingMode( 4 )
canvas.setInterpolationMode( 7 )

canvas.clear( 0xFFFFFFFF )
mainBrush := new GDIp.SolidBrush( 0xFFFF0000 )
canvas.fillRectangle( mainBrush, [ 5, 5, 90, 90 ] )
mainBrush.setColor( 0xFF00FF00 )
canvas.fillRectangle( mainBrush, [ 12, 12, 76, 76 ] )
family := new GDIp.FontFamily( "Arial Black" )
font   := new GDIp.Font( family, 12 )
format := new GDIp.StringFormat( 2 )
mainBrush.setColor( 0xFF000000 )
canvas.drawString( "nnnik's Bild könnte hier sein", font, [15, 15, 70, 70], format, mainBrush )
avatar.saveToFile( "avatar.jpg" )