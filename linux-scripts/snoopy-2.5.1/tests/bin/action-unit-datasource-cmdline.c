/*
 * SNOOPY COMMAND LOGGER
 *
 * Copyright (c) 2015 Bostjan Skufca Jese <bostjan@a2o.si>
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
#include "action-unit-datasource-cmdline.h"
#include "action-common.h"

#include "snoopy.h"
#include "entrypoint/test-cli.h"
#include "datasource/cmdline.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>



/*
 * Local helper functions
 */
static void mockDatasourceCmdline (
    char const * const testId,
    char const * const filename,
    char * const argv[],
    char const * const expectedResult
);



void snoopyTestCli_action_unit_datasource_cmdline_showHelp ()
{
    char * helpContent =
        "Snoopy TEST SUITE CLI utility :: Action `unit` :: Unit `datasource` :: Subunit `cmdline`\n"
        "\n"
        "Description:\n"
        "    Mocks src/datasource/cmdline.c"
        "\n"
        "Usage:\n"
        "    snoopy-test unit datasource cmdline\n"
        "    snoopy-test unit datasource cmdline --help\n"
        "\n";
    printf("%s", helpContent);
}



int snoopyTestCli_action_unit_datasource_cmdline (int argc, char ** argv)
{
    const char *arg1;

    if (argc > 0) {
        arg1 = argv[0];
    } else {
        arg1 = "";
    }

    if (0 == strcmp(arg1, "--help")) {
        snoopyTestCli_action_unit_datasource_cmdline_showHelp();
        return 0;
    }

    // Mock the basics
    mockDatasourceCmdline("test01", "cmdInFn", (char *[]) {"cmdInArgv",                 NULL}, "cmdInArgv");
    mockDatasourceCmdline("test02", "cmdInFn", (char *[]) {"cmdInArgv", "arg1",         NULL}, "cmdInArgv arg1");
    mockDatasourceCmdline("test03", "cmdInFn", (char *[]) {"cmdInArgv", "arg1", "arg2", NULL}, "cmdInArgv arg1 arg2");

    // Edge cases #1
    mockDatasourceCmdline("test11", "cmdInFn", (char *[]) {"cmdInArgv", "arg1", "",     NULL}, "cmdInArgv arg1 ");
    mockDatasourceCmdline("test12", "cmdInFn", (char *[]) {"cmdInArgv", "",     "",     NULL}, "cmdInArgv  ");
    mockDatasourceCmdline("test13", "cmdInFn", (char *[]) {"cmdInArgv", "",     "arg2", NULL}, "cmdInArgv  arg2");
    mockDatasourceCmdline("test14", "cmdInFn", (char *[]) {"",          "",     "",     NULL}, "  ");

    // Edge cases #2
    mockDatasourceCmdline("test21", "cmdInFn", NULL,              "cmdInFn"); // DirectAdmin does this :/
    mockDatasourceCmdline("test22", "cmdInFn", (char *[]) {NULL}, "cmdInFn");
    mockDatasourceCmdline("test23", NULL,      NULL,              "(unknown)");

    // Edge cases #3
    char       * str2045    = "12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345";
    char const * str2045exp = "12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345 1";
    char       * str2047    = "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567";
    char       * str2048    = "12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678";
    mockDatasourceCmdline("test31", str2047,   (char *[]) {              NULL}, str2047);
    mockDatasourceCmdline("test32", str2048,   (char *[]) {              NULL}, str2047);

    mockDatasourceCmdline("test33", "cmdInFn", (char *[]) {str2047,      NULL}, str2047);
    mockDatasourceCmdline("test34", "cmdInFn", (char *[]) {str2048,      NULL}, str2047);

    mockDatasourceCmdline("test35", "cmdInFn", (char *[]) {str2045, "1", NULL}, str2045exp);

    printSuccess("Mocking src/datasource/cmdline.c complete.");
    return 0;
}



static void mockDatasourceCmdline (
    char const * const testId,
    char const * const filename,
    char * const argv[],
    char const * const expectedResult)
{
    char   resultBuf[SNOOPY_DATASOURCE_MESSAGE_MAX_SIZE] = {'\0'};
    char * result = resultBuf;
    int    retVal;

    // Init
    snoopy_entrypoint_test_cli_init(filename, argv, NULL);

    // Run the datasource
    retVal = snoopy_datasource_cmdline(result, NULL);
    if (SNOOPY_DATASOURCE_FAILED(retVal)) {
        fatalErrorValue("Datasource failure", expectedResult);
    }

    // Deinit Snoopy
    snoopy_entrypoint_test_cli_exit();

    // Evaluate the result
    if (0 != strcmp(result, expectedResult)) {
        printDiagValue("Expected result", expectedResult);
        printDiagValue("Actual   result", result);
        fatalErrorValue("Datasource returned unexpected result, testId", testId);
    }

    return;
}