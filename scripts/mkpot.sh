#!/bin/bash

# Generate messages.po
xgettext src/arch-update.sh src/lib/*

# Normalizing messages.po
sed -i '/^#:.*$/N;/\nmsgid "\$(\(echo -e\|info_msg\) "/,/msgstr ""/d' messages.po
sed -i '/^$/N;/^\n$/D' messages.po
sed -i '1,/^#: src\//{ /^#: src\//!d }' messages.po

# Merge messages.po into arch-update.pot
sed -i -e '/^#: src\//,$d' po/arch-update.pot
cat messages.po >> po/arch-update.pot
rm -f messages.po
