import { NativeModules } from 'react-native';
const { EspIdfProvisioning } = NativeModules;

export type BLEDevice = {
  advertisementData: Record<string, string>;
  capabilities: string[];
  versionInfo: Record<string, string>;
} & DiscoveredBLEDevice;

export type DiscoveredBLEDevice = {
  name: string;
};

export type ConnectBleDevice = {
  name: string;
  security: 1 | 0;
  deviceProofOfPossession: string;
};

type EspIdfProvisioning = {
  getBleDevices: (prefix: string) => Promise<DiscoveredBLEDevice>;
  connectBleDevice: (arg: ConnectBleDevice) => Promise<BLEDevice>;
};

export default EspIdfProvisioning as EspIdfProvisioning;
