/*
 * SNOOPY COMMAND LOGGER
 *
 * File: snoopy/datasource/tty__common.c
 *
 * Copyright (c) 2020-2020 Bostjan Skufca <bostjan@a2o.si>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */



/*
 * Includes order: from local to global
 */
#include "tty__common.h"
#include "tty.h"

#include "snoopy.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <pwd.h>



/*
 * SNOOPY DATA SOURCE HELPER: get_tty_uid
 *
 * Description:
 *     Returns UID (User ID) of current controlling terminal, or -1 if not found.
 *
 * Params:
 *     ttyUid: pointer to uid_t to store the result into
 *     result: pointer to string, to write the error into
 *
 * Return:
 *     - 0 on success (result in ttyUid)
 *     - number of characters in the returned string on error
 */
int snoopy_datasource_tty__get_tty_uid (uid_t * ttyUid, char * const result)
{
    char    ttyPath[SNOOPY_DATASOURCE_TTY_sizeMaxWithNull];
    size_t  ttyPathLen = SNOOPY_DATASOURCE_TTY_sizeMaxWithoutNull;
    int     retVal;
    struct  stat statbuffer;

    /* Get tty path */
    retVal = ttyname_r(0, ttyPath, ttyPathLen);
    if (0 != retVal) {
        if (EBADF == retVal) {
            return snprintf(result, SNOOPY_DATASOURCE_MESSAGE_MAX_SIZE, "ERROR(ttyname_r->EBADF)");
        }
        if (ERANGE == retVal) {
            return snprintf(result, SNOOPY_DATASOURCE_MESSAGE_MAX_SIZE, "ERROR(ttyname_r->ERANGE)");
        }
        if (ENOTTY == retVal) {
            return snprintf(result, SNOOPY_DATASOURCE_MESSAGE_MAX_SIZE, "(none)");
        }
        return snprintf(result, SNOOPY_DATASOURCE_MESSAGE_MAX_SIZE, "(unknown)");
    }

    /* Get owner of tty */
    if (-1 == stat(ttyPath, &statbuffer)) {
        return snprintf(result, SNOOPY_DATASOURCE_MESSAGE_MAX_SIZE, "ERROR(unable to stat() %s)", ttyPath);
    }
    *ttyUid = statbuffer.st_uid;

    return 0;
}
