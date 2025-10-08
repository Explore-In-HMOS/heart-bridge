import { CalorieValue } from './CalorieValue';

export interface SamplePoint {
  startTime: number;
  endTime: number;
  dataTypeName: string;
  value: CalorieValue[];
}