import { NativeModules } from 'react-native';
import { promiseTimeout } from './utils';
const { EspIdfProvisioning } = NativeModules;

const CONNECT_TIMEOUT = 30000;

const scanWifiList = async () => {
  try {
    return promiseTimeout(CONNECT_TIMEOUT, EspIdfProvisioning.scanWifiList());
  } catch (error) {
    return error;
  }
};

export default { ...EspIdfProvisioning, scanWifiList };
