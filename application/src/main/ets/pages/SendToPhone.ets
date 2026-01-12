import { util } from '@kit.ArkTS';
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@kit.BasicServicesKit';
import { wearEngine } from '@kit.WearEngine';
import Constants from '../utils/Constants';
import { sensor } from '@kit.SensorServiceKit';
import PermissionsUtil from '../utils/PermissionsUtil';

let appInfo: wearEngine.AppInfo = {
  bundleName: Constants.bundleName,
  fingerprint: Constants.fingerprint
}

let appParam: wearEngine.P2pAppParam = {
  remoteApp: appInfo,
  transformLocalAppInfo: false
}

@Builder
export function SendToPhoneBuilder() {
  SendToPhone()
}

@Entry
@Component
struct SendToPhone {
  @State heartRate: number = 0;
  @State msgFromWatch: string = '';
  receivedLog: string = '';
  deviceClient: wearEngine.DeviceClient = wearEngine.getDeviceClient(this.getUIContext().getHostContext());
  p2pClient: wearEngine.P2pClient = wearEngine.getP2pClient(this.getUIContext().getHostContext());
  context = this.getUIContext().getHostContext();
  deviceList: wearEngine.Device[] = [];
  randomid: string = '';
  messageCallback: Callback<wearEngine.P2pMessage> = (p2pMessage: wearEngine.P2pMessage) => {
    let decoder: util.TextDecoder = new util.TextDecoder();
    this.msgFromWatch = decoder.decodeToString(p2pMessage.content);
    promptAction.openToast({ message: this.msgFromWatch, duration: 1000 });
  }
  private uiContext = this.getUIContext();
  private realContext = this.uiContext.getHostContext()

  aboutToAppear() {
    const INTERVAL = 200000000;
    PermissionsUtil.requestPermissions([
      'ohos.permission.READ_HEALTH_DATA'], this.realContext!)
    sensor.getSensorList((error: BusinessError, data: Array<sensor.Sensor>) => {
      if (error) {
        console.error('getSensorList failed');
      } else {
        console.info('getSensorList success');
        for (let i = 0; i < data.length; i++) {
          console.info(JSON.stringify(data[i]));
        }
      }
    })
    try {
      sensor.on(sensor.SensorId.HEART_RATE, (data: sensor.HeartRateResponse) => {
        this.heartRate = data.heartRate
      }, { interval: INTERVAL });
      setTimeout(() => {
        sensor.off(sensor.SensorId.HEART_RATE);
      }, 500);
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`Failed to invoke on. Code: ${e.code}, message: ${e.message}`);
    }
    this.getConnectedDevices();
  }

  aboutToDisappear() {
    try {
      sensor.off(sensor.SensorId.HEART_RATE);
      console.info('Heart rate sensor unsubscribed');
    } catch (err) {
      console.error(`Error while unsubscribing sensor: ${JSON.stringify(err)}`);
    }
  }

  getConnectedDevices() {
    this.deviceClient.getConnectedDevices().then(devices => {
      this.deviceList = devices;
      for (let index of this.deviceList) {
        this.randomid = index.randomId;
      }
      this.registerReceiver();
    })
  }

  subscribeHeartRateSensor() {
    try {
      sensor.off(sensor.SensorId.HEART_RATE);
      console.info('Heart rate listener removed');
    } catch (err) {
      console.info('No heart rate listener to remove');
    }

    sensor.getSensorList((error: BusinessError, data: Array<sensor.Sensor>) => {
      if (error) {
        return;
      }
      const heartRateSensor = data.find(s => s.sensorName.toLowerCase().includes('heart'));
      if (!heartRateSensor) {
        return;
      }

      sensor.on(sensor.SensorId.HEART_RATE, async (data: sensor.HeartRateResponse) => {
        if (data && data.heartRate !== undefined) {
          this.heartRate = data.heartRate;
          await this.sendMessage(`HeartRate: ${data.heartRate} bpm`);
        }
      }, { interval: 100000000 });
    });
  }

  registerReceiver() {
    this.p2pClient.unregisterMessageReceiver(this.randomid, appParam, () => {
      console.info('unregistered');
    }).catch(() => {
    });

    this.p2pClient.isRemoteAppInstalled(this.randomid, appInfo.bundleName).then(() => {
      this.p2pClient.registerMessageReceiver(this.randomid, appParam, this.messageCallback);
      console.info('registered');
    })
  }

  async sendMessage(content: string) {
    if (!this.randomid) {
      return;
    }
    const textEncoder = new util.TextEncoder();
    const message: wearEngine.P2pMessage = { content: textEncoder.encodeInto(content) };
    try {
      const p2pResult = await this.p2pClient.sendMessage(this.randomid, appParam, message);
    } catch (err) {
      console.error(`SendMessage Error: ${JSON.stringify(err)}`);
    }
  }

  build() {
    NavDestination() {
      Column({ space: 20 }) {
        Image($r('app.media.heartrate')).width(50).height(50)
        Text(`Heart Rate: ${this.heartRate} bpm`)
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor(Color.Red)

        Text(`From Phone: ${this.msgFromWatch}`)
          .fontColor(Color.Gray)
        Text(this.receivedLog).fontColor(Color.Gray)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
    }
    .hideBackButton(true)
  }
}