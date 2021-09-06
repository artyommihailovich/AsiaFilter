//
//  ViewController.swift
//  AsiaFilter
//
//  Created by Artyom Mihailovich on 8/18/21.
//

import UIKit
import AVKit
import ARKit
import RealityKit
import CoreImage.CIFilterBuiltins

final class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    private var context: CIContext?
    private var device: MTLDevice!
    
    private var videoPlayer: AVPlayer!
    
    private var entity: ModelEntity!
    private let anchorEntity = AnchorEntity(plane: .horizontal)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.setupARConfiguration()
        postEffect(arView: arView)
        obtainSphereEntity()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.obtainPeopleOcclusion()
    }
    
    func postEffect(arView: ARView) {
        arView.renderCallbacks.prepareWithDevice = { [weak self] device in
            self?.prepareWithDevice(device)
        }
        arView.renderCallbacks.postProcess = { [weak self] context in
            self?.postProcess(context)
        }
    }
    
    func prepareWithDevice(_ device: MTLDevice) {
        self.context = CIContext(mtlDevice: device)
        self.device = device
    }
    
    func postProcess(_ context: ARView.PostProcessContext) {
        filter(context)
    }
    
    func filter(_ context: ARView.PostProcessContext) {
        let inputImage = CIImage(mtlTexture: context.sourceColorTexture)!

        let filter = CIFilter.photoEffectNoir()
        filter.inputImage = inputImage
        
        let destination = CIRenderDestination(mtlTexture: context.targetColorTexture,
                                              commandBuffer: context.commandBuffer)
        
        destination.isFlipped = false
        
        _ = try? self.context?.startTask(toRender: filter.outputImage!, to: destination)
    }
    
    func obtainSphereEntity() {
        guard let path = Bundle.main.path(forResource: "Jellyfish", ofType: "mp4") else { return }
        let url = URL(fileURLWithPath: path)
        let playerItem = AVPlayerItem(url: url)
        videoPlayer =  AVPlayer(playerItem: playerItem)

        let mesh = MeshResource.generateSphere(radius: 0.5)
        let material = VideoMaterial(avPlayer: videoPlayer)

        entity = ModelEntity(mesh: mesh, materials: [material])
        entity.generateCollisionShapes(recursive: true)
        entity.setParent(anchorEntity)
        entity.position.y = 0.8
        
        videoPlayer.play()

        arView.installGestures(.all, for: entity)
        arView.scene.anchors.append(anchorEntity)

        NotificationCenter.default.addObserver(self, selector: #selector(loopVideo),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    @objc
    private func loopVideo(notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem else { return }
        playerItem.seek(to: CMTime.zero, completionHandler: nil)
        videoPlayer.play()
    }
}
