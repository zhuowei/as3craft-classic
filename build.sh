#!/bin/sh
amxmlc -theme+=themefix.css -omit-trace-statements=false -compiler.debug=true -static-link-runtime-shared-libraries -locale=en_US -source-path+=locale/{locale} -source-path+=lib -incremental=true -keep-generated-actionscript=true AS3Craft.mxml
