//
//  findfont.swift
//
//  A really quickly thrown together piece of code to locate where a font is
//  on a Mac, because Apple didn't provide a utility for some reason :G
//
//  Created by Joe Simpson on 01/12/2014.
//  Copyright (c) 2014 kennydude. All rights reserved.
//

import Foundation
import AppKit

if(Process.arguments.count != 2){
  println("Usage: ./findfont \"Font Name\"");
  exit(-1);
} else{
  
  var font = NSFont(name: Process.arguments[1], size: 22.0);
  
  if(font != nil){

    var fontRef = CTFontDescriptorCreateWithNameAndSize(Process.arguments[1], 22.0);
    var url: CFURLRef = CTFontDescriptorCopyAttribute(fontRef, kCTFontURLAttribute) as CFURLRef;
  
    var path:NSString = CFURLCopyPath(url) as NSString;
    var realPath:NSString = path.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!;
  
    println(realPath);

  } else{
    exit(-1);
  }

}