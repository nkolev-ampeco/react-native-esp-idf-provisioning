declare module 'react-native-esp-idf-provisioning' {
  export interface BLEDeveice {
    name: string;
    id: string;
  }
  export function getBleDevices(): Promise<BLEDevice>;
}
