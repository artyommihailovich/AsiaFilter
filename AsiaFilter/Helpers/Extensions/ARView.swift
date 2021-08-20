//
//  ARView.swift
//  ARView
//
//  Created by Artyom Mihailovich on 8/19/21.
//

import ARKit
import RealityKit

extension ARView {
    func setupARConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        self.session.run(configuration)
    }
    
    func obtainPeopleOcclusion() {
         guard let configuration = self.session.configuration as? ARWorldTrackingConfiguration else {
             fatalError("DEBUGGER: - Unexpectedly failed to get the configuration.")
         }
         guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
             fatalError("DEBUGGER: - People occlusion is not supported on this device.")
         }
         configuration.frameSemantics.insert(.personSegmentationWithDepth)
         self.session.run(configuration)
    }
}
