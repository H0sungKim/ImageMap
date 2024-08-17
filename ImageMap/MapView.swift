//
//  MyView.swift
//  GettingStarted
//
//  Created by Yuri Strot on 11/9/16.
//  Copyright © 2016 Exyte. All rights reserved.
//

import Macaw

class MapView: MacawView {
    private var mapNode: Group
    weak var delegate: MapDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        let map = try! SVGParser.parse(resource: "korea")
        mapNode = Group(contents: [map], place: .identity)
        super.init(node: mapNode, coder: aDecoder)
        
        for province in ProvinceManager.shared.provinces {
            map.nodeBy(tag: String(province.id))?.onTouchPressed({ [weak self] touch in
                print("A")
                
                self?.delegate?.presentProvinceSheet(provinceName: province.name)
                if let shape = touch.node as? Shape {
                    let select: Shape = Shape(
                        form: shape.form,
                        stroke: Stroke(fill: Color.red, width: shape.stroke!.width*3),
                        place: shape.place,
                        clip: shape.clip
                    )
                    self?.mapNode.contents.append(select)
                }
                print(self?.mapNode.contents.count)
            })
        }
    }
    
    func setBackGroundImage(node: Node, image: UIImage) {
        if let shape = node as? Shape {
            let backgroundShape = Shape(form: Rect(0, 0, shape.bounds!.x+shape.bounds!.w, shape.bounds!.y+shape.bounds!.h))
            let image = Image(
                image: image,
                aspectRatio: .slice,
                w: Int(shape.bounds!.w),
                h: Int(shape.bounds!.h)
            )
            image.place = .move(shape.bounds!.x+(shape.bounds!.w-image.bounds!.w)/2, shape.bounds!.y+(shape.bounds!.h-image.bounds!.h)/2)
            let resizedImage = Group(contents: [backgroundShape, image])
            shape.fill = Pattern(content: resizedImage, bounds: resizedImage.bounds!, userSpace: true)
        }
    }
    
    func transformMapNode(origin: CGPoint, size: CGSize) {
//        print("size : \(size), bounds : \(mapNode.bounds)")
        mapNode.place = Transform().move(-origin.x, -origin.y).scale(min(size.width/mapNode.bounds!.w, size.height/mapNode.bounds!.h), min(size.width/mapNode.bounds!.w, size.height/mapNode.bounds!.h))
//        print(mapNode.place.m11)
//        print(mapNode.place.m22)
    }
    override func touchesBegan(_ touches: Set<MTouch>, with event: MEvent?) {
        print("b")
        delegate?.dismissProvinceSheet()
        mapNode.contents.removeSubrange(1..<mapNode.contents.count)
        super.touchesBegan(touches, with: event)
        print(mapNode.contents.count)
    }
}

protocol MapDelegate: AnyObject {
    func dismissProvinceSheet()
    func presentProvinceSheet(provinceName: String)
}
