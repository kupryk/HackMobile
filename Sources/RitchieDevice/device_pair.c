//
//  device_pair.c
//  
//
//  Created by Mikita Kupryk on 23/12/2023.
//

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <libimobiledevice/lockdown.h>
#include <libimobiledevice/libimobiledevice.h>

#include "clogger.h"

bool pairDevice(const char* udid, enum idevice_options lookup_ops) {
    idevice_t device = NULL;
    lockdownd_client_t client = NULL;

    if (IDEVICE_E_SUCCESS != idevice_new_with_options(&device, udid, lookup_ops)) {
        LOG_ERROR("Device \"%s\": Not found.", udid);
        return false;
    }

    lockdownd_error_t ldret = LOCKDOWN_E_UNKNOWN_ERROR;
    
    if (LOCKDOWN_E_SUCCESS != (ldret = lockdownd_client_new_with_handshake(device, &client, "devicepair"))) {
        LOG_ERROR("Device \"%s\": Could not connect to lockdownd, error code %d.", udid, ldret);
        idevice_free(device);
        return false;
    }

    idevice_free(device);
    lockdownd_client_free(client);

    return true;
}
