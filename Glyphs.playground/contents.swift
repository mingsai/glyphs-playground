import CoreText
import Foundation
import UIKit
import QuartzCore
import XCPlayground

//research layers
//var l:CALayer? = nil
//var txt:CATextLayer? = nil
//var r:CAReplicatorLayer? = nil
//var tile:CATiledLayer? = nil
//var trans:CATransformLayer? = nil
//var b:CAAnimation?=nil

//  Setup playground to run in full simulator (⌘-0:Select Playground File; ⌘-alt-0:Choose option Run in Full Simulator)

//approach 2 using a custom stroke font requires special font without an outline whose path is the actual fill
var customFontPath = NSBundle.mainBundle().pathForResource("cwTeXFangSong-zhonly", ofType: "ttf")

//  Within the playground folder create Resources folder to hold fonts. NB - Sources folder can also be created to hold additional Swift files
//ORTE1LOT.otf
//NISC18030.ttf
//cwTeXFangSong-zhonly
//cwTeXHei-zhonly
//cwTeXKai-zhonly
//cwTeXMing-zhonly
//cwTeXYen-zhonly

var customFontData = NSData(contentsOfFile: customFontPath!) as! CFDataRef
var error:UnsafeMutablePointer<Unmanaged<CFError>?> = nil
var provider:CGDataProviderRef = CGDataProviderCreateWithCFData ( customFontData )
var customFont = CGFontCreateWithDataProvider(provider) as CGFont!

let registered =  CTFontManagerRegisterGraphicsFont(customFont, error)

if !registered  {
    println("Failed to load custom font: ")
 
}

let string:NSString = "五"
//"ABCDEFGHIJKLMNOPQRSTUVWXYZ一二三四五六七八九十什我是美国人"

//use the Postscript name of the font
let font =  CTFontCreateWithName("cwTeXFangSong", 72, nil)
//HiraMinProN-W6
//WeibeiTC-Bold
//OrachTechDemo1Lotf
//XinGothic-Pleco-W4
//GB18030 Bitmap

var count = string.length

//must initialize with buffer to enable assignment within CTFontGetGlyphsForCharacters
var glyphs = Array<CGGlyph>(count: string.length, repeatedValue: 0)
var chars = [UniChar]()

for index in 0..<string.length {
    
    chars.append(string.characterAtIndex(index))
    
}

//println ("\(chars)") //ok

//println(font)
//println(chars)
//println(chars.count)
//println(glyphs.count)

let gotGlyphs = CTFontGetGlyphsForCharacters(font, &chars, &glyphs, chars.count)

//println(glyphs)
//println(glyphs.count)

if gotGlyphs {
    
    // loop and pass paths to animation function
    let cgpath = CTFontCreatePathForGlyph(font, glyphs[0], nil)

    //how to break the path apart?
    let path = UIBezierPath(CGPath: cgpath)
    //path.hashValue
    //println(path)
    
    //  all shapes are closed paths
    //  how to distinguish overlapping shapes, confluence points connected by line segments?
    //  compare curve angles to identify stroke type
    //  for curves that intersect find confluence points and create separate line segments by adding the linesegmens between the gap areas of the intersection
    
    /* analysis of movepoint
    
        This method implicitly ends the current subpath (if any) and 
        sets the current point to the value in the point parameter. 
        When ending the previous subpath, this method does not actually 
        close the subpath. Therefore, the first and last points of the 
        previous subpath are not connected to each other.
    
        For many path operations, you must call this method before 
        issuing any commands that cause a line or curve segment to be 
        drawn.
*/
    
    
    //CGPathApplierFunction should allow one to add behavior to each glyph obtained from a string (Swift version??)
    
//    func processPathElement(info:Void,  element: CGPathElement?) {
//        var pointsForPathElement=[UnsafeMutablePointer<CGPoint>]()
//        if let e = element?.points{
//            pointsForPathElement.append(e)
//            
//        }
//    }
//    
//    var pathArray = [CGPathElement]() as! CFMutableArrayRef
    
    //var pathArray = Array<CGPathElement>(count: 4, repeatedValue: 0)
    
    //CGPathApply(<#path: CGPath!#>, <#info: UnsafeMutablePointer<Void>#>, function: CGPathApplierFunction)
    
    
//    CGPathApply(path.CGPath, info: &pathArray, function:processPathElement)
    
    /*
    NSMutableArray *pathElements = [NSMutableArray arrayWithCapacity:1];
    // This contains an array of paths, drawn to this current view
    CFMutableArrayRef existingPaths = displayingView.pathArray;
    CFIndex pathCount = CFArrayGetCount(existingPaths);
    for( int i=0; i < pathCount; i++ ) {
    CGMutablePathRef pRef = (CGMutablePathRef) CFArrayGetValueAtIndex(existingPaths, i);
    CGPathApply(pRef, pathElements, processPathElement);
    }
    */
    
    //given the structure
    let pathString = path.description
//    println(pathString)
    //regex patthern matcher to produce subpaths?
    //...
    //must be simpler method
    //...
    
    /* 
        NOTES:
        Use assistant editor to view 
        UIBezierPath String
    
        http://www.google.com/fonts/earlyaccess
        Stroke-based fonts
        Donald Knuth
    
    */
//    var redColor = UIColor.redColor()
//    redColor.setStroke()
    
    
    var pathLayer = CAShapeLayer()
    pathLayer.frame = CGRect(origin: CGPointZero, size: CGSizeMake(300.0,300.0))
    pathLayer.lineJoin = kCALineJoinRound
    pathLayer.lineCap = kCALineCapRound
    //pathLayer.backgroundColor = UIColor.whiteColor().CGColor
    pathLayer.strokeColor = UIColor.redColor().CGColor
    pathLayer.path = path.CGPath
    
    
    //    pathLayer.backgroundColor = UIColor.redColor().CGColor
    
    // regarding strokeStart, strokeEnd
    /* These values define the subregion of the path used to draw the
    * stroked outline. The values must be in the range [0,1] with zero
    * representing the start of the path and one the end. Values in
    * between zero and one are interpolated linearly along the path
    * length. strokeStart defaults to zero and strokeEnd to one. Both are
    * animatable. */
    var pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
    pathAnimation.duration = 10.0
    pathAnimation.fromValue = NSNumber(float: 0.0)
    pathAnimation.toValue = NSNumber(float: 1.0)
   
    /*
    var fillAnimation = CABasicAnimation (keyPath: "fill")
    fillAnimation.fromValue = UIColor.blackColor().CGColor
    fillAnimation.toValue = UIColor.blueColor().CGColor
    fillAnimation.duration = 10.0
   pathLayer.addAnimation(fillAnimation, forKey: "fillAnimation") */
    
    //given actual behavior of boundary animation, it is more likely that some other animation will better simulate a written stroke
    
    var someView = UIView(frame: CGRect(origin: CGPointZero, size: CGSizeMake(300.0, 300.0)))
    someView.layer.addSublayer(pathLayer)
    

    //SHOW VIEW IN CONSOLE (ASSISTANT EDITOR)
     XCPShowView("b4Animation", someView)
    
    pathLayer.addAnimation(pathAnimation, forKey: "strokeEndAnimation")
    
    someView.layer.addSublayer(pathLayer)
    
    XCPShowView("Animation", someView)
    
    
    
    
}
