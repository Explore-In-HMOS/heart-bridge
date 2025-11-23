import { BusinessError } from '@kit.BasicServicesKit';
import { TokenResponse } from '../model/TokenResponse';
import { CalorieDataResult } from '../model/CalorieDataResult';
import { CaloriesViewModel } from '../viewmodel/CaloriesViewModel';

@Builder
export function CaloriesPageBuilder() {
  CaloriesPage()
}

@Entry
@Component
export struct CaloriesPage {
  @State accessToken: string = '';
  @State caloriesList: number[] = []; // save calories here
  @State timesList: string[] = []; // save start and end times here
  @State isLoading: boolean = true;
  private viewModel = new CaloriesViewModel();
  @Consume('mainStack') pathStack: NavPathStack;
  @State token: TokenResponse = {
    access_token: '',
    expires_in: 0,
    id_token: '',
    refresh_token: '',
    scope: '',
    token_type: ''
  }

  aboutToAppear(): void {
    this.token = this.pathStack.getParamByName('CaloriesPage')[0] as TokenResponse

    if (this.token) {
      console.info('Received token:', this.token.access_token);
      this.viewModel.getCalories(this.token.access_token)
        .then((result: CalorieDataResult) => {
          this.caloriesList = result.calories;
          this.timesList = result.times;
          this.isLoading = false;
          console.info(`Fetched calories: ${result.calories}, times: ${result.times}`);
        })
        .catch((e: BusinessError) => {
          console.error('Calories fetch failed:', e);
          this.isLoading = false;
        });

    } else {
      console.error('No access token found.');
    }
  }

  build() {
    NavDestination() {
      Column() {
        if (this.isLoading) {
          Text($r('app.string.loading'))
            .fontSize(16);
        } else if (this.caloriesList.length === 0) {
          Text($r('app.string.no_calorie'))
            .fontSize(16);
        } else {
          Text(`Calories`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold);

          List({ space: 2 }) {
            ForEach(this.caloriesList, (calorie: number, index: number) => {
              ListItem() {
                Column() {
                  Text(`${calorie} kcal`)
                    .fontSize(14)
                    .fontColor(Color.Green)
                    .fontWeight(FontWeight.Bold);

                  // Show start time
                  if (this.timesList.length > index * 2) {
                    Text(`Start: ${this.timesList[index * 2]}`)
                      .fontSize(12)
                  }

                  // Show end time
                  if (this.timesList.length > index * 2 + 1) {
                    Text(`End: ${this.timesList[index * 2 + 1]}`)
                      .fontSize(12)
                  }
                }
                .padding(6)
              }
              .width('100%')
            }, (item: string, index: number) => item)
          }
          .width('100%')
          .height('100%')
        }
      }
      .margin({ top: 10, bottom: 30 })
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
    }
    .hideBackButton(true)
  }
}