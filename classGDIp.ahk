﻿/*
	API GDIp
	author:			nnnik
	
	description:	A class based wrapper around the GDI+ API based on gdip.ahk made by tick
	
	general:		I don't feel like creating a documentation for this right now
*/
#include %A_LineFile%\..\indirectReference.ahk

class GDIp
{
	
	static openObjects := []
	static references  := 0
	
	__New()
	{
		if !( GDIp.hasKey( "refObj" ) )
		{
			refObj := { base:{ __Delete: GDIp.DeleterefObj } }
			if !( GDIp.Startup() )
				return
			GDIp.refObj := &refObj
			return refObj
		}
		return Object( GDIp.refObj )
	}
	
	DeleterefObj()
	{
		GDIp.Delete( "refObj" )
		GDIp.Shutdown()
	}
	
	Startup()
	{
		if !( GDIp.references++ )
		{
			if !( DllCall( "GetModuleHandle", "Str", "gdiplus", "Ptr" ) )
				if !( DllCall( "LoadLibrary", "Str", "gdiplus" ) )
					return 0
			VarSetCapacity( si, A_PtrSize = 8 ? 24 : 16, 0 )
			si := Chr(1)
			DllCall( "gdiplus\GdiplusStartup","Ptr*", pToken, "Ptr", &si, "Ptr", 0 )
			if ( pToken )
				GDIp.Token := pToken
			return pToken
		}
	}
	
	Shutdown()
	{
		if ( !( --GDIp.references ) )
		{
			For each, GDIpObject in GDIp.openObjects
				GDIpObject.__Delete()
			DllCall( "gdiplus\GdiplusShutdown", "Ptr", GDIp.Token )
			if ( hModule := DllCall( "GetModuleHandle", "Str", "gdiplus", "Ptr" ) )
				DllCall( "FreeLibrary", "Ptr", hModule )
		}
	}
	
	class Bitmap
	{
		
		__New( filePathOrSize )
		{
			if isObject( filePathOrSize )
				ret := DllCall( "gdiplus\GdipCreateBitmapFromScan0", "UInt", filePathOrSize.1, "UInt", filePathOrSize.2, "UInt", 0, "UInt", 0x26200A, "Ptr", 0, "Ptr*", pBitmap )
			else if fileExist( filePathOrSize )
				ret := DllCall( "gdiplus\GdipCreateBitmapFromFile", "WStr", filePathOrSize, "Ptr*", pBitmap )
			if ret
				return ret
			This.ptr := pBitmap
			GDIp.registerObject( This )
		}
		
		__Delete()
		{
			if ( This.hasKey( "pGraphics" ) )
				This.pGraphics.__Delete()
			DllCall("gdiplus\GdipDisposeImage", "Ptr", This.ptr )
			GDIp.unregisterObject( This )
			This.base := "" ;prevent all bad calls to gdiplus.dll by disconnecting the base and freeing all references towards such functions from the object
		}
		
		getGraphics()
		{
			if !( This.hasKey( "pGraphics" ) )
			{
				This.pGraphics := new GDIp.Graphics( This )
			}
			return This.pGraphics
		}
		
		getpBitmap()
		{
			return This.ptr
		}
		
		getSize()
		{
			DllCall( "gdiplus\GdipGetImageWidth",  "Ptr", pBitmap, "UInt*", w )
			DllCall( "gdiplus\GdipGetImageHeight", "Ptr", pBitmap, "UInt*", h )
			return [ w, h ]
		}
		
		saveToFile( fileName )
		{
			RegExMatch( fileName, "\.\w+$", Extension )
			DllCall( "gdiplus\GdipGetImageEncodersSize", "UInt*", nCount, "UInt*", nSize )
			VarSetCapacity( ci, nSize )
			DllCall( "gdiplus\GdipGetImageEncoders", "UInt", nCount, "UInt", nSize, "Ptr", &ci )
			Loop, %nCount%
			{
				sString := StrGet( NumGet( ci, ( idx := ( 48 + 7 * A_PtrSize ) * ( A_Index - 1 ) ) + 32 + 3 * A_PtrSize ), "UTF-16" )
				if InStr( sString, "*" . Extension )
				{
					pCodec := &ci+idx
					break
				}
			}
			DllCall("gdiplus\GdipSaveImageToFile", "Ptr", This.ptr, "WStr", fileName, "Ptr", pCodec, "UInt", 0)
		}
	}
	
	class Graphics
	{
		
		__New( bitmapOrDC )
		{
			if ( pBitmap := bitmapOrDC.getpBitmap() )
				ret := DllCall( "gdiplus\GdipGetImageGraphicsContext", "Ptr", pBitmap, "Ptr*", pGraphics )
			else if ( hDC := bitmapOrDC.gethDC() )
				ret := DllCall( "gdiplus\GdipCreateFromHDC", "Ptr", hDC, "Ptr*", pGraphics )
			if ret
				return ret
			This.ptr := pGraphics
			GDIp.registerObject( This )
		}
		
		__Delete()
		{
			GDIp.unregisterObject( This )
			DllCall( "gdiplus\GdipDeleteGraphics", "Ptr", This.ptr )
			This.base := ""
		}
		
		drawBitmap( Bitmap, tRect , sRect, imageAttributes := 0 )
		{
			return DllCall( "gdiplus\GdipDrawImageRectRect", "Ptr", This.ptr, "Ptr", Bitmap.getpBitmap(), "float", tRect.1, "float", tRect.2, "float", tRect.3, "float", tRect.4, "float", sRect.1, "float", sRect.2, "float", sRect.3, "float", sRect.4, "UInt", 2, "Ptr", isObject( imageAttributes ) ? imageAttributes.ptr : imageAttributes , "Ptr", 0, "Ptr", 0 )
		}
		
		; Default = 0
		; HighSpeed = 1
		; HighQuality = 2
		; None = 3
		; AntiAlias = 4
		
		setSmoothingMode( smoothingMode )
		{
			return DllCall( "gdiplus\GdipSetSmoothingMode", "Ptr", This.ptr, "Int", smoothingMode )
		}
		
		; Default = 0
		; LowQuality = 1
		; HighQuality = 2
		; Bilinear = 3
		; Bicubic = 4
		; NearestNeighbor = 5
		; HighQualityBilinear = 6
		; HighQualityBicubic = 7
		
		setInterpolationMode( interpolationMode )
		{
			return DllCall( "gdiplus\GdipSetInterpolationMode", "Ptr", This.ptr, "Int", interpolationMode )
		}
		
		clear( color = 0 )
		{
			return DllCall("gdiplus\GdipGraphicsClear", "Ptr", This.ptr, "UInt", color )
		}
		
		getpGraphics()
		{
			return This.ptr
		}
		
		rotateCanvasTableAroundPoint( x, y, angle )
		{
			This.moveCanvasTable( -x, -y )
			This.rotateCanvasTable( angle )
			This.moveCanvasTable( x, y )
		}
		
		rotateCanvasTable( angle )
		{
			return DllCall( "gdiplus\GdipRotateWorldTransform", "Ptr", This.ptr, "Float", angle, "Int", 1 )
		}
		
		scaleCanvasTable( xScale, yScale )
		{
			return DllCall("gdiplus\GdipScaleWorldTransform", "Ptr", This.ptr, "Float", xScale, "Float", yScale, "Int", 1 )
		}
		
		moveCanvasTable( x, y )
		{
			return DllCall( "gdiplus\GdipTranslateWorldTransform", "Ptr", This.ptr, "Float", x, "Float", y, "Int", 1 )
		}
		
		resetCanvasTable()
		{
			return DllCall( "gdiplus\GdipResetWorldTransform", "Ptr", This.ptr )
		}
		
		fillRectangle( brush, rect )
		{
			return DllCall( "gdiplus\GdipFillRectangle", "Ptr", This.ptr, "Ptr", ? brush.getpBrush(), "float", rect.1, "float", rect.2, "float", rect.3, "float", rect.4 )
		}
		
		fillElipse( brush, rect )
		{
			return DllCall("gdiplus\GdipFillEllipse", "Ptr", This.ptr, "Ptr", brush.getpBrush(), "float", rect.1, "float", rect.2, "float", rect.3, "float", rect.4 )
		}
		
		/*
			Brush:	the brush used to fill the Polygon
			
			Points:	an array of [ x, y ] values in pixels
			
			FillMode: 1 or 0 Don't really know what it does though
		*/
		
		fillPolygon( brush, points, fillMode=0 )
		{
			VarSetCapacity( pointBuffer, 8 * points.Length(), 0 )
			For pointNr, point in points
			{
				NumPut( point.1, pointBuffer, pointNr * 8 - 8, "float" )
				NumPut( point.2, pointBuffer, pointNr * 8 - 4, "float" )
			}
			return DllCall( "gdiplus\GdipFillPolygon", "Ptr", This.ptr, "Ptr", brush.getpBrush(), "Ptr", &pointBuffer, "int", points.Length(), "int", fillMode )
		}
		
		/*
			Brush:	the brush used to fill the Pie
			
			Rect:     a 4 value array defining the Area the pie occupies
			
			Angles:   a 2 value array defining the starting and the ending angle of the pie
		*/
		
		fillPie( brush, rect, angles )
		{
			return DllCall("gdiplus\GdipFillPie", "Ptr", This.ptr, "Ptr", brush.getpBrush(), "float", rect.1, "float", rect.2, "float", rect.3, "float", rect.4, "float", angles.1, "float", angles.2 )
		}
		
		/*
			Pen:		the pen used to draw the line
			
			Points:	the starting and the end point in a 2x2 array
			
		*/
		
		drawLine( pen, points )
		{
			return DllCall( "gdiplus\GdipDrawLine", "UPtr", This.ptr, "UPtr", pen.getpPen(), "float", points.1.1, "float", points.1.2, "float", points.2.1, "float", points.2.2 )
		}
		
		drawLines( pen, points )
		{
			points := points.clone()
			Loop % points.Length() - 1
				This.drawLine( pen, points ), points.removeAt( 1 )
		}
		
	}
	
	class ImageAttributes
	{
		
		__New()
		{
			if ret := DllCall( "gdiplus\GdipCreateImageAttributes", "UPtr*", imageAttr )
				return ret
			This.ptr := imageAttr
			GDIp.registerObject( This )
		}
		
		__Delete()
		{
			GDIp.unregisterObject( This )
			DllCall( "gdiplus\GdipDisposeImageAttributes", "UPtr", This.ptr )
			This.base := ""
		}
		
		setColorMatrix( Matrix )
		{
			static colourMatrix := ""
			VarSetCapacity( colourMatrix, 100, 0 )
			for x, column in Matrix
				for y, value in column
					NumPut( value, colourMatrix, x*20 + y*4 - 24, "float" )
			DllCall( "gdiplus\GdipSetImageAttributesColorMatrix", "UPtr", This.ptr, "Int", 1, "Int", 1, "UPtr", &colourMatrix, "UPtr", 0, "Int", 0 )
		}
		
		getpImageAttributes()
		{
			return This.ptr
		}
		
	}
	
	class Brush
	{
		
		__New( color )
		{
			if ret := DllCall( "gdiplus\GdipCreateSolidFill", "UInt", color, "UPtr*", pBrush )
				return ret
			This.ptr := pBrush
			GDIp.registerObject( This )
		}
		
		__Delete()
		{
			GDIp.unregisterObject( This )
			DllCall( "gdiplus\GdipDeleteBrush", "UPtr", This.ptr )
			This.base := ""
		}
		getpBrush()
		{
			return This.ptr
		}
		
		Clone()
		{
			if ret := DllCall( "gdiplus\GdipCloneBrush", "UPtr", This.ptr, "UPtr*", brush2 )
				return ret
			newBrush := { ptr: brush2, base: This.base }
			GDIp.registerObject( newBrush )
			return newBrush
		}
		
		setColor( color )
		{
			DllCall( "gdiplus\GdipSetSolidFillColor", "UPtr", This.ptr, "UInt", color )
		}
		
		
		getColor()
		{
			DllCall( "gdiplus\GdipSetSolidFillColor", "UPtr", This.ptr, "UInt*", color )
			return color
		}
		
		
		class LinearGradientBrush extends GDIp.Brush
		{
			
			/*
				creates a new LinearGradientBrush
				color: 				2 ARGB colours in a Array
				
				rectOrPoints:   		specifies the size of the gradient to be drawn
				rect:			4 array values in pixels that describe the size of the gradient thats to be painted
				points:			2x2 array values that define the size and direction of the gradient
				
				
				gradientTypeOrAngle:	specifies the direction of the gradient ( only used with Rect )
				gradientType:		one of 4 values describing the directions from 0 - 3 : 
				Horizontal = 0 Vertical = 1 ForwardDiagonal = 2 BackwardDiagonal = 3
				angle:			any value not from 0-3 or any float ( e.g. 1.000 ) will be treated as an angle to describe the direction
				
				wrapMode:				specifies how the pattern is repeated once it exceeds the defined space in rectOrPoints
				Repeat = 0 RepeatFlipX = 1 RepeatFlipY = 2 ReeatFlipXY = 3 Clamp = 4
				
			*/
			
			__New( color, rectOrPoints, gradientTypeOrAngle := 0 , wrapMode := 0 )
			{
				static rectOrPointF := "", Init := VarSetCapacity( rectOrPointF, 16, 0 )
				if ( rectOrPoints.MaxIndex() = 2 )
				{
					for pointNr, point in rectOrPoints
						for dimension, value in point
							NumPut( value, rectOrPointF, pointNr * 8 + dimension * 4 - 12, "float" )
					ret := DllCall( "gdiplus\GdipCreateLineBrush", "UPtr", &rectOrPointF, "UPtr", &rectOrPointF + 8, "UInt", color.1, "UInt", color.2, "UInt", wrapMode, "UPtr*", pBrush )
				}
				else 
				{
					for dimension, value in rectOrPoints
						NumPut( value, rectOrPointF, dimension * 4 - 4, "float" )
					if ( mod( gradientTypeOrAngle, 4 ) . "" == Round( gradientTypeOrAngle ) . "" ) ;I felt so cool when I found this solution
						ret := DllCall( "gdiplus\GdipCreateLineBrushFromRect", "UPtr", &rectOrPointF, "UInt", color.1, "UInt", color.2, "UInt", gradientTypeOrAngle, "UInt", wrapMode, "UPtr*", pBrush )
					else
						ret := DllCall( "gdiplus\GdipCreateLineBrushFromRectWithAngle", "UPtr", &rectOrPointF, "UInt", color.1, "UInt", color.2, "double", gradientTypeOrAngle, "UInt", 0, "UInt", wrapMode, "UPtr*", pBrush ) ; I don't really know what the 0 parameter does here
				}
				if ret
					return ret
				This.ptr := pBrush
				GDIp.registerObject( This )
			}
			
			__Delete()
			{
				GDIp.unregisterObject( This )
				DllCall( "gdiplus\GdipDeleteBrush", "UPtr", This.ptr )
				This.base := ""
			}
			
			setColor( color )
			{
				color1 := color.1
				color2 := color.2
				DllCall( "gdiplus\GdipSetLineColors", "UPtr", This.ptr, "UInt", color1, "UInt", color2 )
			}
			
			getColor()
			{
				VarSetCapacity( colors, 8, 0 )
				DllCall( "gdiplus\GdipGetLineColors", "UPtr", This.ptr, "Ptr", &colors )
				return [ numGet( colors, 0, "UInt" ), numGet( colors, 4, "UInt" ) ]
			}
			
		}
		
		
	}
	
	class Pen
	{
		__New( brushOrColor, width )
		{
			if isObject( brushOrColor )
				ret := DllCall( "gdiplus\GdipCreatePen2", "UPtr", brushOrColor.getpBrush(), "float", width, "int", 2, "UPtr*", pPen )
			else
				ret := DllCall( "gdiplus\GdipCreatePen1", "UInt", ARGB, "float", width, "Int", 2, "UPtr*", pPen )
			if ret
				return ret
			This.ptr := pPen
			GDIp.registerObject( This )
		}
		
		__Delete()
		{
			DllCall( "gdiplus\GdipDeletePen", "UPtr", This.ptr )
			GDIp.unregisterObject( This )
			This.base := ""
		}
		
		clone()
		{
			ret := DllCall( "gdiplus\GdipClonePen", "UPtr", This.ptr, "UPtr*", pPen )
			if ret
				return ret
			newPen := { ptr: pPen ,base: GDIp.pen }
			GDIp.registerObject( newPen )
			return newPen
		}
		
		getpPen()
		{
			return This.ptr
		}
		
		setWidth( width )
		{
			return DllCall( "gdiplus\GdipSetPenWidth", "UPtr", This.ptr, "float", width )
		}
		
		getWidth()
		{
			DllCall( "gdiplus\GdipGetPenWidth", "UPtr", This.ptr, "float*", width )
			return width
		}
		
		setColor( color )
		{
			return DllCall( "gdiplus\GdipSetPenColor", "UPtr", Ths.ptr, "UInt", color )
		}
		
		getColor()
		{
			DllCall( "gdiplus\GdipGetPenColor", "UPtr", This.ptr, "UInt*", color )
			return color
		}
		
		setBrush( brush )
		{
			return DllCall( "gdiplus\GdipSetPenBrushFill", "UPtr", This.ptr, "UPtr", brush.getpBrush() )
		}
		
		getBrush()
		{
			return
		}
		
	}
	
	registerObject( Object )
	{
		This.openObjects[ &Object ] := new indirectReference( Object , { __Delete: 1 } )
	}
	
	unregisterObject( Object )
	{
		This.openObjects.Delete( &Object )
	}
	
}

class GDI
{
	class DC
	{
		
		__New( hWND )
		{
			if !hDC  := DllCall( "GetDC", "Ptr", hWND, "Ptr" )
				return
			This.hWND := hWND
			This.hDC  := hDC
		}
		
		__Delete()
		{
			This.pGraphics.__Delete()
			DllCall( "ReleaseDC", "Ptr", This.hWND, "Ptr", This.hDC )
			This.base := ""
		}
		
		gethDC()
		{
			return This.hDC
		}
		
		getGraphics()
		{
			if !( This.hasKey( "pGraphics" ) )
				This.pGraphics := new GDIp.Graphics( This )
			return This.pGraphics
		}
		
	}
}