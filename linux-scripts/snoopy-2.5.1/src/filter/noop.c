/*
 * SNOOPY COMMAND LOGGER
 *
 * File: snoopy/datasource/noop.c
 *
 * Copyright (c) 2014-2015 Bostjan Skufca <bostjan@a2o.si>
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
#include "noop.h"

#include "snoopy.h"



/*
 * SNOOPY FILTER: noop
 *
 * Description:
 *     Does nothing (just passes).
 *
 * Params:
 *     result: pointer to string, to write result into
 *     arg:    (ignored)
 *
 * Return:
 *     SNOOPY_FILTER_PASS
 */
int snoopy_filter_noop(__attribute__((unused)) char const * const arg)
{
    return SNOOPY_FILTER_PASS;
}
