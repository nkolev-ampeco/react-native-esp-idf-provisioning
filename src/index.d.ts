declare module 'react-native-esp-idf-provisioning' {
  export type BLEDevice = {
    advertisementData: {
      kCBAdvDataRxSecondaryPHY: number;
      kCBAdvDataLocalName: string;
      kCBAdvDataRxPrimaryPHY: number;
      kCBAdvDataTimestamp: number;
      kCBAdvDataIsConnectable: nulber;
      kCBAdvDataServiceUUIDs: string[];
    };
    capabilities: string[];
    versionInfo: { prov: { ver: string; cap: string[] } };
  } & DiscoveredBLEDevice;

  export type DiscoveredBLEDevice = {
    name: string;
  };

  export function getBleDevices(prefix: string): Promise<DiscoveredBLEDevice>;
  export interface ConnectBleDevice {
    name: string;
    security: 1 | 0;
    deviceProofOfPossession: string;
  }

  export function connectBleDevice(arg: ConnectBleDevice): Promise<BLEDevice>;

  export type WiFi = {
    security: WifiSecurity;
    name: string;
    rssi: number;
  };

  enum WifiSecurity {
    Open = 1,
    Wep,
    WpaPsk,
    wpa2Psk,
    wpaWpa2Psk,
    wpa2Enterprise,
  }

  export interface Provision {
    ssid: string;
    passPhrase: string;
  }

  export function scanWifiList(): Promise<WiFi[]>;

  export function provision(arg: Provision): Promise<void>;

  export function disconnectBLEDeviceIfConnected(): void;
}
