import UIKit
import MetalKit
import simd

class CircleView: UIView {
  
  // MARK: Metal
  private var metalView: MTKView!
  private var device: MTLDevice!
  private var commandQueue: MTLCommandQueue!
  private var rendererPipelineState: MTLRenderPipelineState!
  
  private var vertexBuffer: MTLBuffer!
  
  // MARK: Vertices
  private var circleVertices = [simd_float2]()
  
  // MARK: Initialize
  init() {
    super.init(frame: .zero)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.makeCircleVertices()
    self.setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Set up
  private func setupView() {
    self.metalView = MTKView()
    self.addSubview(self.metalView)
    self.metalView.framebufferOnly = true
    self.metalView.translatesAutoresizingMaskIntoConstraints = false
    self.metalView.delegate = self
    
    // second drawing modes
    // https://developer.apple.com/documentation/metalkit/mtkview
    self.metalView.isPaused = true
    self.metalView.enableSetNeedsDisplay = true
    
    // connect to GPU
    self.device = MTLCreateSystemDefaultDevice()
    self.metalView.device = device
    
    // create command queue
    self.commandQueue = self.device.makeCommandQueue()
    
    // creating render pipeline state
    self.createPipelineState()
    
    self.vertexBuffer = self.device.makeBuffer(bytes: self.circleVertices, length: self.circleVertices.count * MemoryLayout<simd_float2>.stride)
    
    // draw
    self.metalView.setNeedsDisplay()
  }
  
  // MARK: create pipeline state (use shader)
  private func createPipelineState() {
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    
    let library = self.device.makeDefaultLibrary()!
    
    pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
    pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
    
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    self.rendererPipelineState = try! self.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
  }
  
  // MARK: Create Circle Vertices
  private func makeCircleVertices() {
    let origin = simd_float2(0, 0)

    for i in 0 ... 720 {
      let position: simd_float2 = [cos(rad(Float(i) / 2.0)), sin(rad(Float(i) / 2.0))]
      self.circleVertices.append(position)
      if (i + 1) % 2 == 0 {
        self.circleVertices.append(origin)
      }
    }
  }
  
  // MARK: degree to radian
  private func rad(_ degree: Float) -> Float {
    return (degree * Float.pi) / 180
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.metalView.pin.all()
  }
}

extension CircleView: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    
  }
  
  func draw(in view: MTKView) {
    // create commandbuffer
    guard let commandBuffer = self.commandQueue.makeCommandBuffer() else { return }
    
    // create the interface for the pipeline
    guard let renderDescriptor = view.currentRenderPassDescriptor else { return }
    
    // setting background color as blue
    renderDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 1, 1)
    
    // create and configure internal information of pipeline
    guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor) else { return }
    
    renderEncoder.setRenderPipelineState(self.rendererPipelineState)
    renderEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, index: 0)
    renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: self.circleVertices.count)
    
    // end encoding
    renderEncoder.endEncoding()
    
    // tell the GPU where to send the randered result
    commandBuffer.present(view.currentDrawable!)
    
    // add the instruction to commandqueue
    commandBuffer.commit()
  }
}
