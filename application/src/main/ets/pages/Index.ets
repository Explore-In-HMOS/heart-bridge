import { ButtonComponent } from '../component/ButtonComponent';

@Entry
@Component
struct Index {
  @Provide('mainStack') pathStack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.pathStack) {

      Column() {
        ButtonComponent({ text: 'Heart Flow' })
          .padding({ bottom: 5 })
          .onClick(() => {
            this.pathStack.pushPathByName('SendToPhone', null)
          })

        ButtonComponent({ text: 'Authentication' })
          .onClick(() => {
            this.pathStack.pushPathByName('AuthenticationPage', null)
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .hideTitleBar(true)
  }
}