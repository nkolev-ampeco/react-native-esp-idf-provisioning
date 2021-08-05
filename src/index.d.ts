declare module 'react-native-esp-idf-provisioning' {
  export interface BLEDevice {
    name: string;
    address: string;
  }
  export function getBleDevices(prefix: string): Promise<BLEDevice>;
  export interface ConnectBleDevice {
    deviceAddress: string;
    security: 1 | 0;
    deviceProofOfPossession: string;
  }
  export function connectBleDevice(arg: ConnectBleDevice): Promise<any>;
}
