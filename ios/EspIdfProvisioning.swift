import Alamofire
import ESPProvision

class EspDevice {
  static let shared = EspDevice()
  var espDevice: ESPDevice?
  func setDevice(device: ESPDevice) {
    self.espDevice = device
  }
}

public enum ConnectEventNames: String {
    case connected = "connected"
    case failedToConnect = "connection_failed"
    case disconnected  = "disconnected"
}
public enum ProvisionEventNames: String {
    case configApplied = "config_applied"
    case success  = "success"
    case failedToProvision = "provision_failed"
}

@objc(EspIdfProvisioning)
class EspIdfProvisioning: RCTEventEmitter {
    private var security: ESPSecurity = .secure

    var bleDevices:[ESPDevice]?

    @objc(createDevice:devicePassword:deviceProofOfPossession:successCallback:)
    func createDevice(_ deviceName: String, devicePassword: String, deviceProofOfPossession: String, successCallback: @escaping RCTResponseSenderBlock) -> Void {
      ESPProvisionManager.shared.createESPDevice(
          deviceName: deviceName,
          transport: ESPTransport.softap,
          security: ESPSecurity.secure,
          proofOfPossession: deviceProofOfPossession,
          softAPPassword: devicePassword
      ){ espDevice, _ in
          dump(espDevice)
          EspDevice.shared.setDevice(device: espDevice!)
          successCallback([nil, "success"])
      }

    }

    // Searches for BLE devices with a name starting with the given prefix.
    // The prefix must match the string in '/main/app_main.c'
    // Resolves to an array of BLE devices
    @objc(getBleDevices:withResolver:withRejecter:)
    func getBleDevices(prefix: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {

      ESPProvisionManager.shared.searchESPDevices(devicePrefix:prefix, transport:.ble) { bleDevices, error in
        DispatchQueue.main.async {
          if bleDevices == nil {
            let error = NSError(domain: "getBleDevices", code: 404, userInfo: [NSLocalizedDescriptionKey : "No devices found"])
            reject("404", "getBleDevices", error)

            return
          }

          let deviceNames = bleDevices!.map {[
            "name": $0.name,
            "security":$0.security.rawValue
          ]}

          resolve(deviceNames)
        }
      }
    }

    // Connects to a BLE device
    // We need the Service UUID from the config.service_uuid in app_prov.c
    // We need the proof of possestion (pop) specified in '/main/app_main.c'
    // The deviceAddress is the address we got from the "getBleDevices" function
    // Resolves when connected to device
    @objc(connectBleDevice:security:deviceProofOfPossession:withResolver:withRejecter:)
    func connectBleDevice(deviceAddress: String, security: Int = 1, deviceProofOfPossession: String? = nil, resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {

        ESPProvisionManager.shared.createESPDevice(deviceName: deviceAddress, transport: .ble, security: security == 1 ? .secure : .unsecure, proofOfPossession: deviceProofOfPossession, completionHandler: { device, _ in
          if device == nil {
            let error = NSError(domain: "connectBleDevice", code: 400, userInfo: [NSLocalizedDescriptionKey : "Device not found"])
            reject("400", "Device not found", error)

            return
          }

          let espDevice: ESPDevice = device!
          EspDevice.shared.setDevice(device: espDevice)

          espDevice.connect(completionHandler: { [unowned self] status in
              switch status {
              case .connected:
                  let response: [String: Any] = [
                      "event_name": ConnectEventNames.connected.rawValue,
                      "name": espDevice.name,
                      "capabilities": espDevice.capabilities ?? [],
                      "versionInfo": espDevice.versionInfo ?? {
                      }
                  ]
                  self.sendEvent(withName: "DeviceConnectionEvent", body: response)
                  resolve(response)
              case .failedToConnect(_):
                  let error = NSError(domain: "connectBleDevice", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to connect"])
                  let response: [String: Any] = [
                      "event_name": ConnectEventNames.failedToConnect.rawValue
                  ]
                  self.sendEvent(withName: "DeviceConnectionEvent", body: response)
                  reject(ConnectEventNames.failedToConnect.rawValue, "Failed to connect", error)
              default:
                  let error = NSError(domain: "connectBleDevice", code: 404, userInfo: [NSLocalizedDescriptionKey: "Default connection error"])
                  let response: [String: Any] = [
                      "event_name": ConnectEventNames.disconnected.rawValue
                  ]
                  self.sendEvent(withName: "DeviceConnectionEvent", body: response)
                  reject(ConnectEventNames.disconnected.rawValue, "Default connection error", error)
              }
          })
      })
    }

    @objc(scanWifiList:withRejecter:)
    func scanWifiList(resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
      EspDevice.shared.espDevice?.scanWifiList{ wifiList, _ in

        let networks = wifiList?.map {[
            "name": $0.ssid,
            "rssi": $0.rssi,
            "security": $0.auth.rawValue,
        ]}

        resolve(networks)
      }
    }

    @objc(provision:passPhrase:withResolver:withRejecter:)
    func provision(ssid: String, passPhrase: String, resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        var completedFlag = false
        EspDevice.shared.espDevice?.provision(ssid: ssid, passPhrase: passPhrase, completionHandler: {
            status in
            dump(status)
            if (!completedFlag) {
                switch status {
                case .configApplied:
                    let response: [String: Any] = [
                        "event_name": ProvisionEventNames.configApplied.rawValue,
                    ]
                    self.sendEvent(withName: "DeviceProvisionEvent", body: response)
                case .success:
                    let response: [String: Any] = [
                        "event_name": ProvisionEventNames.success.rawValue,
                    ]
                    self.sendEvent(withName: "DeviceProvisionEvent", body: response)
                    completedFlag = true
                    resolve(response)
                case let .failure(espError):
                    let message:String;
                    switch espError {
                       case .configurationError:
                           message = "configurationError"
                       case .sessionError:
                            message = "sessionError"
                       case .wifiStatusAuthenticationError:
                            message = "wifiStatusAuthenticationError"
                       default:
                            message = String(describing: espError)
                       }
                    let error = NSError(domain: "provision", code: 400, userInfo: [NSLocalizedDescriptionKey: String(describing: espError)])
                    let response: [String: Any] = [
                        "event_name": ProvisionEventNames.failedToProvision.rawValue,
                        "error": message
                    ]
                    self.sendEvent(withName: "DeviceProvisionEvent", body: response)
                    completedFlag = true
                    reject("400", "Default connection error", error)
                }

            }

        })
    }

    @objc(disconnectBLEDeviceIfConnected)
    func disconnectBLEDeviceIfConnected() -> Void {
        EspDevice.shared.espDevice?.disconnect()
    }

    @objc(supportedEvents)
    override func supportedEvents() -> [String] {
        return ["DeviceConnectionEvent","DeviceProvisionEvent"]
    }

}
