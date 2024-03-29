import Foundation
import MultipeerConnectivity
import Compression

public let IntrospectionClientServiceName = "compose-client"

class IntrospectionClient : NSObject, ObservableObject {
    
    ///Internal identifier of a client
    fileprivate let discoveryInfo = [
        "id" : UUID().uuidString
    ]
    
    ///Current peer identifier.
    #if os(iOS)
    fileprivate let peerIdentifier = MCPeerID(displayName: Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? UIDevice.current.name)
    #else
    fileprivate let peerIdentifier = MCPeerID(displayName: Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? Host.current().localizedName ?? "Mac")
    #endif
    
    ///Currently active session.
    fileprivate let session : MCSession
    
    ///Service advertiser to let Compose  know about this device.
    fileprivate let advertiser : MCNearbyServiceAdvertiser
    
    @Published fileprivate(set) var connectionState : ConnectionState = .disconnected
    
    override init() {
        self.advertiser = MCNearbyServiceAdvertiser(peer: peerIdentifier,
                                                    discoveryInfo: discoveryInfo,
                                                    serviceType: IntrospectionClientServiceName)
        
        self.session = MCSession(peer: peerIdentifier, securityIdentity: nil, encryptionPreference: .none)
        
        super.init()
        
        session.delegate = self
        
        self.advertiser.delegate = self
        self.advertiser.startAdvertisingPeer()
        
        #if os(iOS)
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                                object: nil,
                                                queue: .main) { [unowned self] notification in
            self.session.disconnect()
            self.advertiser.stopAdvertisingPeer()
         }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                               object: nil,
                                               queue: .main) { [unowned self] notification in
            self.advertiser.startAdvertisingPeer()
        }
        #endif
        
        print("[Compose] Introspection client is ready.")
    }
    
}

extension IntrospectionClient {
    
    func send<T : Encodable>(_ value : T) throws {
        guard session.connectedPeers.count > 0 else {
            return
        }
        
        guard connectionState == .connected else {
            return
        }

        print("[Compose] Sending data...")
        
        let encoder = PropertyListEncoder()
        
        let encodedData = try encoder.encode(value)
        var data = Data()
        
        let outputFilter = try OutputFilter(.compress,
                                            using: .lzfse) { compressedData -> Void in
            if let compressedData = compressedData {
                data.append(compressedData)
            }
        }
        
        var index = 0
        let bufferSize = encodedData.count
        
        while true {
            let rangeLength = min(256, bufferSize - index)
            
            let subdata = encodedData.subdata(in: index ..< index + rangeLength)
            index += rangeLength
            
            try outputFilter.write(subdata)
            
            if (rangeLength == 0) {
                break
            }
        }
        
        try send(data)
    }
    
    func send(_ data : Data) throws {
        guard session.connectedPeers.count > 0 else {
            return
        }
        
        guard connectionState == .connected else {
            return
        }
        
        try session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }
    
}

extension IntrospectionClient : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didNotStartAdvertisingPeer error: Error) {
        print("[Compose] Error while advertising remote rendering client: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
        print("[Compose] Introspection session initiated.")
    }
    
}

extension IntrospectionClient : MCSessionDelegate {
    
    ///State of connection with the server.
    enum ConnectionState {
        
        ///Connected to remote host, but idle
        case connected
        
        ///Disconnected from remote host
        case disconnected
    }
    
    func session(_ session: MCSession,
                 peer peerID: MCPeerID,
                 didChange state: MCSessionState) {
        switch state {
        
        case .notConnected:
            print("[Compose] Not connected to server")
            self.connectionState = .disconnected
            
        case .connecting:
            print("[Compose] Connecting to server")
            
        case .connected:
            print("[Compose] Connected to server")
            self.connectionState = .connected
            
        default:
            break
            
        }
    }
    
    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession,
                 didReceive stream: InputStream,
                 withName streamName: String,
                 fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: Error?) {
       
    }
    
}
