> **Note:** To access all shared projects, get information about environment setup, and view other guides, please visit [Explore-In-HMOS Index](https://github.com/Explore-In-HMOS/hmos-index).

# Heart Bridge
This app demonstrates an application that runs with **HarmonyOS Next** wearable devices. It enables seamless interaction between the wearable and a paired mobile device by combining real-time sensor data with health insights. Users can track their heart rate instantly, share it with their phone, and view calorie data retrieved from Huawei Health. 

# Preview

<div>
<img src="./screenshots/HomeOutput.png" width="25%"/>
<img src="./screenshots/CaloriesOutput.png" width="25%"/>
<img src="./screenshots/HeartRateOutput.png" width="25%"/>
</div>

# Use Cases

1) The user can measure the heart rate as real time with sensor.
2) The user can send the hear rate to the mobile app.
3) The user can see the calories that coming from Huawei Health.
4) Receive messages on phone from the HMOS Next Wearable.

# Tech Stack

- **Languages**: ArkTS
- **Frameworks**: HarmonyOS SDK 5.1.0(18)
- **Tools**: DevEco Studio Vers 5.1.0.842
- **Libraries**:
    - `@kit.ArkUI`
    - `@kit.AbilityKit`
    - `@kit.PerformanceAnalysisKit`
    - `@kit.ArkWeb`
    - `@kit.NetworkKit`
    - `@kit.ArkTS`
    - `@kit.BasicServicesKit`
    - `@kit.WearEngine`
    - `@kit.SensorServiceKit`

# Directory Structure
   ```
entry/src/main/ets/
|---component
|---|---ButtonComponent
|---hiwearmainability
|---|---HiWearMainAbility
|---model
|---|---CalorieDataResult
|---|---CalorieGroup
|---|---CalorieResponse
|---|---CalorieValue
|---|---PolymerizeWithItem
|---|---SamplePoint
|---|---SampleSet
|---|---TokenResponse
|---pages
|---|---AuthenticationPage
|---|---CaloriesPage
|---|---Index
|---|---SendToPhone
|---utils
|---|---APIConstants
|---|---Constants
|---|---Preferences
|---|---processRespTask
|---viewmodel
|---|---AuthenticationViewModel
|---|---CaloriesViewModel
   ```

# Constraints and Restrictions
## Requirements
1. Configure signing settings.
2. Change module.json with your phone app bundle name.
3. Change the values on Constants.ets with your values.
4. Change watch app bundle name with your bundle name.

## Supported Devices
- Huawei Watch 5
## Permissions
- ohos.permission.INTERNET
- ohos.permission.READ_HEALTH_DATA

# License
**Heart Bridge** is distributed under the terms of the MIT License
See the [LICENSE](./LICENSE) for more information.
