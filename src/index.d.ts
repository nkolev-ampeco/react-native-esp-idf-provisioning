declare module 'react-native-esp-idf-provisioning' {
  export type BLEDevice = {
    advertisementData: Record<string, string>;
    capabilities: string[];
    versionInfo: Record<string, string>;
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
}
