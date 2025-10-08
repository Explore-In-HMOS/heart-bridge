import { router } from '@kit.ArkUI'
import { ButtonComponent } from '../component/ButtonComponent';

@Entry
@Component
struct Index {
  build() {
    Column() {
      ButtonComponent({ text: 'Heart Flow' })
        .padding({ bottom: 5 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/SendToPhone',
          });
        })

      ButtonComponent({ text: 'Authentication' })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/AuthenticationPage'
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}