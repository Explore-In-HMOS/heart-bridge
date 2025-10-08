import { SampleSet } from './SampleSet';

export interface CalorieGroup {
  startTime: number;
  endTime: number;
  sampleSet: SampleSet[];
}