#!/bin/sh
mxmlc -omit-trace-statements=false -compiler.debug=true -static-link-runtime-shared-libraries -locale=en_US -source-path=locale/{locale} AS3Craft.mxml
