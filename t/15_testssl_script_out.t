#!/usr/bin/env perl
# Copyright 2016 Glenn ten Cate
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ------------------------------------------------------------------------------
# This little script checks testssl json output to IVIL 
# ------------------------------------------------------------------------------

use strict;
use Test::More tests => 1;

print `perl -MSeccubusV2 -I SeccubusV2 bin/testssl2ivil --scanner nmap --timestamp 200001010000 --infile testdata/testssl.json --outfile ./tmp.json.ivil.xml`;
my $ivil = `cat ./tmp.json.ivil.xml`;
like($ivil,qr/NOT ok</,"Testssl json output is in ivil output");
unlink "./tmp.json.ivil.xml";
