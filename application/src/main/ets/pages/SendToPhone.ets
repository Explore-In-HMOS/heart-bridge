import { util } from '@kit.ArkTS';
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { wearEngine } from '@kit.WearEngine';
import Constants from '../utils/Constants';
import { sensor } from '@kit.SensorServiceKit';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';

let appInfo: wearEngine.AppInfo = {
  bundleName: Constants.bundleName,
  fingerprint: Constants.fingerprint
}

let appParam: wearEngine.P2pAppParam = {
  remoteApp: appInfo,
  transformLocalAppInfo: false
}

@Entry
@Component
struct HeartRateAndAutoSend {
  @State heartRate: number = 0;
  @State msgFromWatch: string = '';
  @State receivedLog: string = '';
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

  aboutToAppear() {
    this.requestHealthPermission();
    this.getConnectedDevices();
  }

  aboutToDisappear() {
    try {
      sensor.off(sensor.SensorId.HEART_RATE);
      console.info('Heart rate sensor unsubscribed');
    } catch (err) {
      console.error('Error while unsubscribing sensor: ' + JSON.stringify(err));
    }
  }

  async requestHealthPermission() {
    const context = getContext(this);
    const atManager = abilityAccessCtrl.createAtManager();
    const permissions: Permissions[] = ['ohos.permission.READ_HEALTH_DATA'];
    try {
      const result = await atManager.requestPermissionsFromUser(context, permissions);
      if (result.authResults.every(r => r === 0)) {
        this.subscribeHeartRateSensor();
      }
    } catch (err) {
      console.error('Permission err: ' + JSON.stringify(err));
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
    const message: wearEngine.P2pMessage = { content: textEncoder.encode(content) };
    try {
      const p2pResult = await this.p2pClient.sendMessage(this.randomid, appParam, message);
      hilog.info(0, 'WearEngine', 'Message sent: ' + content + ' result: ' + p2pResult.code);
    } catch (err) {
      console.error('SendMessage Error: ' + JSON.stringify(err));
    }
  }

  build() {
    Column({ space: 20 }) {
      Image($r('app.media.heartrate')).width(50).height(50)
      Text('Heart Rate: ' + this.heartRate + ' bpm')
        .fontSize(20).fontWeight(FontWeight.Bold).fontColor(Color.Red)

      Text('From Phone: ' + this.msgFromWatch).fontColor(Color.Gray)
      Text(this.receivedLog).fontColor(Color.Gray)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}