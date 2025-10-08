import { webview } from '@kit.ArkWeb';
import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { AuthenticationViewModel } from '../viewmodel/AuthenticationViewModel';
import Constants from '../utils/Constants';

@Entry
@Component
export struct Authentication {
  @State shouldShowWebView: boolean = true;
  @State accessToken: string = '';
  @State activationKey: string = '';
  controller: webview.WebviewController = new webview.WebviewController();
  private viewModel = new AuthenticationViewModel();

  aboutToAppear(): void {
    const storedToken = this.viewModel.getAccessTokenFromStorage();
    if (storedToken.length > 0) {
      this.accessToken = storedToken;
      this.shouldShowWebView = false;
    }
  }

  handleOAuthCode(code: string) {
    this.activationKey = code;
    this.shouldShowWebView = false;

    this.viewModel.postOAuthToken(code).then((token) => {
      if (token) {
        this.accessToken = token;
      }
    }).catch((e: BusinessError) => {
      console.error('Token exchange failed:', e);
    });
  }

  build() {
    Column() {
      if (this.shouldShowWebView) {
        Web({ src: Constants.AUTH_URL, controller: this.controller })
          .width('100%')
          .height('100%')
          .onLoadIntercept((event) => {
            if (event) {
              const url = event.data.getRequestUrl();
              console.log('URL:' + url);
              const code = this.viewModel.getQueryParameter(url, 'code');
              if (code) {
                console.info('Code received from redirect: ' + code);
                this.handleOAuthCode(code);
              }
            }
            return false;
          });
      } else {
        Column() {
          Text($r('app.string.access_token'))
            .fontSize(14)
            .height('20%')
            .width('100%')
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center);

          Text(this.accessToken)
            .fontSize(12)
            .height('30%')
            .width('100%')
            .fontColor(Color.Red)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/CaloriesPage',
                params: { access_token: this.accessToken }
              });
            });
        }
        .height('100%')
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .height('100%')
    .width('100%');
  }
}
