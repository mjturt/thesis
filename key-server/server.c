/* SPDX-License-Identifier: LGPL-3.0-or-later */
/* Copyright (C) 2020 Intel Labs */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "secret_prov.h"

#define PORT "4433"
#define SRV_CRT_PATH "./ssl/server.crt"
#define SRV_KEY_PATH "./ssl/server.key"

int main(void) {
    FILE* ptr;
    char str[50];
    ptr = fopen("../model-trainer/key.key","a+");

    if (NULL == ptr) {
        printf("file can't be opened \n");
    }

    fgets(str, 50, ptr);
    puts("--- Starting the Secret Provisioning server on port " PORT " ---");
    int ret = secret_provision_start_server(str, sizeof(str),
                                            PORT, SRV_CRT_PATH, SRV_KEY_PATH,
                                            NULL, NULL);
    fclose(ptr);
    if (ret < 0) {
        fprintf(stderr, "[error] secret_provision_start_server() returned %d\n", ret);
        return 1;
    }
    return 0;
}
