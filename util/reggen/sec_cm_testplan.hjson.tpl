// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Security countermeasures testplan extracted from the IP Hjson using reggen.
//
// This testplan is auto-generated only the first time it is created. This is
// because this testplan needs to be hand-editable. It is possible that these
// testpoints can go out of date if the spec is updated with new
// countermeasures. When `reggen` is invoked when this testplan already exists,
// It checks if the list of testpoints is up-to-date and enforces the user to
// make further manual updates.
//
// These countermeasures and their descriptions can be found here:
// .../${block_name}/data/${block_name}.hjson
//
// It is possible that the testing of some of these countermeasures may already
// be covered as a testpoint in a different testplan. This duplication is ok -
// the test would have likely already been developed. We simply map those tests
// to the testpoints below using the `tests` key.
//
// Please ensure that this testplan is imported in:
// .../${block_name}/data/${block_name}_testplan.hjson
{
<%
def get_sec_cm_testpoint_name(cm):
    cm_name = str(cm).lower().replace(".", "_")
    return f"sec_cm_{cm_name}"
%>\
  testpoints: [
% for cm in block.countermeasures:
    {
      name: ${get_sec_cm_testpoint_name(cm)}
      desc: "Verify the countermeasure(s) ${str(cm)}."
      stage: V2S
      tests: []
    }
% endfor
  ]
}
