//
//  ritchie_device.h
//
//
//  Created by Mikita Kupryk on 23/12/2023.
//

#ifndef ritchie_device_h
#define ritchie_device_h

#include <stdbool.h>
#include <libimobiledevice/libimobiledevice.h>

#define DEV_ACTION_REVEAL 0 // 0 = reveal toggle in settings
#define DEV_ACTION_ENABLE 1 // 1 = enable developer mode (only if no passcode is set)
#define DEV_ACTION_PROMPT 2 // 2 = answers developer mode enable prompt post-restart

bool pairDevice(const char* udid, enum idevice_options lookup_ops);
bool developerImageIsMountedForDevice(const char *udid, enum idevice_options lookup_ops);
bool mountImageForDevice(const char *udid, const char *devDMG, const char *devSign, enum idevice_options lookup_ops);

const char *deviceName(const char *udid, enum idevice_options lookup_ops);
const char *deviceProductName(const char *udid, enum idevice_options lookup_ops);
const char *deviceProductVersion(const char *udid, enum idevice_options lookup_ops);

bool enableDeveloperMode(const char *udid, enum idevice_options lookup_ops);
bool developerModeIsEnabledForDevice(const char *udid, enum idevice_options lookup_ops);

#endif /* ritchie_device_h */
