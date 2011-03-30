#!/bin/sh
bash gendate.sh
amxmlc -theme+=themefix.css -omit-trace-statements=true -compiler.debug=false -static-link-runtime-shared-libraries -locale=en_US -source-path+=locale/{locale} -source-path+=lib AS3Craft.mxml
