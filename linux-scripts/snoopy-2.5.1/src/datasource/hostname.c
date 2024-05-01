/*
 * SNOOPY COMMAND LOGGER
 *
 * File: snoopy/datasource/hostname.c
 *
 * Copyright (c) 2015 Bostjan Skufca <bostjan@a2o.si>
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
#include "hostname.h"

#include "snoopy.h"

#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>



/*
 * SNOOPY DATA SOURCE: hostname
 *
 * Description:
 *     Returns hostname of this system.
 *
 * Params:
 *     result: pointer to string, to write result into
 *     arg:    (ignored)
 *
 * Return:
 *     number of characters in the returned string, or SNOOPY_DATASOURCE_FAILURE
 */
int snoopy_datasource_hostname (char * const result, __attribute__((unused)) char const * const arg)
{
    int   charCount;
    int   retVal;

    retVal = gethostname(result, SNOOPY_DATASOURCE_MESSAGE_MAX_SIZE);
    if (0 != retVal) {
        return snprintf(result, SNOOPY_DATASOURCE_MESSAGE_MAX_SIZE, "(error @ gethostname(): %d)", errno);
    }

    // If hostname was something alien (longer than 1024 characters),
    // set last char to null just in case
    result[SNOOPY_DATASOURCE_MESSAGE_MAX_SIZE-1] = '\0';
    charCount = (int) strlen(result);
    return charCount;
}
