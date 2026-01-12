import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { sampleSet } from '../utils/APIConstants';
import { PolymerizeWithItem } from '../model/PolymerizeWithItem';
import { CalorieGroup } from '../model/CalorieGroup';
import { SampleSet } from '../model/SampleSet';
import { SamplePoint } from '../model/SamplePoint';
import { CalorieValue } from '../model/CalorieValue';
import { CalorieDataResult } from '../model/CalorieDataResult';
import taskpool from '@ohos.taskpool';
import { CalorieResponse } from '../model/CalorieResponse';
import { processRespTask } from '../utils/processRespTask';


export class CaloriesViewModel {
  // Nanosecond to millisecond conversion helper
  private nanoToMillis(nano: number): number {
    return Math.floor(nano / 1_000_000);
  }

  // fetch calorie data
  async fetchCalorieData(accessToken: string): Promise<CalorieDataResult> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();
      const url = sampleSet;

      const polymerizeWith: PolymerizeWithItem[] = [
        { dataTypeName: 'com.huawei.continuous.calories.burnt' }
      ];

      const body = JSON.stringify({
        polymerizeWith: polymerizeWith,
        startTime: 1757510126000,
        endTime: 1758201326000
      });

      const headers: Record<string, string> = {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      };

      httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: headers,
          extraData: body,
          expectDataType: http.HttpDataType.STRING
        },
        async (err: BusinessError, data: http.HttpResponse) => {
          let task = new taskpool.Task(processRespTask, [err, data]);
          await taskpool.execute(task);

          const result = typeof data.result === 'string' ?
            JSON.parse(data.result) as CalorieResponse :
            data.result as CalorieResponse;

          const calories: number[] = [];
          const times: string[] = [];

          result.group.forEach((groupItem: CalorieGroup) => {
            groupItem.sampleSet.forEach((set: SampleSet) => {
              set.samplePoints.forEach((point: SamplePoint) => {
                point.value.forEach((v: CalorieValue) => {
                  if (v.fieldName === 'calories') {
                    const formatter = new Intl.DateTimeFormat(undefined, {
                      dateStyle: 'short',
                      timeStyle: 'medium'
                    });

                    const startMillis = this.nanoToMillis(point.startTime);
                    const endMillis = this.nanoToMillis(point.endTime);

                    const startDateStr = formatter.format(startMillis);
                    const endDateStr = formatter.format(endMillis);

                    calories.push(v.floatValue);
                    times.push(startDateStr);
                    times.push(endDateStr);

                    let task = new taskpool.Task(processRespTask, [err, data]);
                    taskpool.execute(task);

                    console.info(
                      `Calories: ${v.floatValue} startTime: ${startDateStr} endTime: ${endDateStr}`
                    );
                  }
                });
              });
            });
          });

          resolve({ calories, times });
        }
      );
    });
  }

  getCalories(accessToken: string): Promise<CalorieDataResult> {
    return this.fetchCalorieData(accessToken);
  }
}