#############################################################################
# File          : SignatureCheck.py
# Package       : rpmlint
# Author        : Frederic Lepied
# Created on    : Thu Oct  7 17:06:14 1999
# Version       : $Id$
# Purpose       : check the presence of a PGP signature.
#############################################################################

from Filter import *
import AbstractCheck
import re
import sys

class SignatureCheck(AbstractCheck.AbstractCheck):
    pgp_regex=re.compile("pgp|gpg", re.IGNORECASE)
    unknown_key_regex=re.compile("\(MISSING KEYS:\s+([^\)]+)\)")

    def __init__(self):
        AbstractCheck.AbstractCheck.__init__(self, "SignatureCheck")

    def check(self, pkg):
        res=pkg.checkSignature()
        if not res or res[0] != 0:
            if res and res[1]:
                kres=SignatureCheck.unknown_key_regex.search(res[1])
            else:
                kres=None
            if kres:
                printError(pkg, "unknown-key", kres.group(1))
            else:
                sys.stderr.write("error checking signature of " + pkg.filename + "\n")
        else:
            if not SignatureCheck.pgp_regex.search(res[1]):
                printError(pkg, "no-signature")

# Create an object to enable the auto registration of the test
check=SignatureCheck()

if Config.info:
    addDetails(
'no-signature',
'''You have to include your pgp or gpg signature in your package.
For more information on signatures, please refer to www.gnupg.org.''',
'unknown-key',
'''The package was signed, but with an unknown key.
See the rpm --import option for more information.''',

)

# SignatureCheck.py ends here

# Local variables:
# indent-tabs-mode: nil
# py-indent-offset: 4
# End:
# ex: ts=4 sw=4 et
