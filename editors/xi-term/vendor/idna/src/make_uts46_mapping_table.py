# Copyright 2013-2014 The rust-url developers.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

# Run as: python make_uts46_mapping_table.py IdnaMappingTable.txt > uts46_mapping_table.rs
# You can get the latest idna table from
# http://www.unicode.org/Public/idna/latest/IdnaMappingTable.txt

import collections
import itertools

print('''\
// Copyright 2013-2014 The rust-url developers.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

// Generated by make_idna_table.py

static TABLE: &'static [Range] = &[
''')

txt = open("IdnaMappingTable.txt")

def escape_char(c):
    return "\\u{%x}" % ord(c[0])

def char(s):
    return unichr(int(s, 16))

strtab = collections.OrderedDict()
strtab_offset = 0

def strtab_slice(s):
    global strtab, strtab_offset

    if s in strtab:
        return strtab[s]
    else:
        utf8_len = len(s.encode('utf8'))
        c = (strtab_offset, utf8_len)
        strtab[s] = c
        strtab_offset += utf8_len
        return c

def rust_slice(s):
    start = s[0]
    length = s[1]
    start_lo = start & 0xff
    start_hi = start >> 8
    assert length <= 255
    assert start_hi <= 255
    return "(StringTableSlice { byte_start_lo: %d, byte_start_hi: %d, byte_len: %d })" % (start_lo, start_hi, length)

ranges = []

for line in txt:
    # remove comments
    line, _, _ = line.partition('#')
    # skip empty lines
    if len(line.strip()) == 0:
        continue
    fields = line.split(';')
    if fields[0].strip() == 'D800..DFFF':
        continue  # Surrogates don't occur in Rust strings.
    first, _, last = fields[0].strip().partition('..')
    if not last:
        last = first
    mapping = fields[1].strip().replace('_', ' ').title().replace(' ', '')
    unicode_str = None
    if len(fields) > 2:
        if fields[2].strip():
            unicode_str = u''.join(char(c) for c in fields[2].strip().split(' '))
        elif mapping == "Deviation":
            unicode_str = u''
    ranges.append((first, last, mapping, unicode_str))

def mergeable_key(r):
    mapping = r[2]
    # These types have associated data, so we should not merge them.
    if mapping in ('Mapped', 'Deviation', 'DisallowedStd3Mapped'):
        return r
    assert mapping in ('Valid', 'Ignored', 'Disallowed', 'DisallowedStd3Valid')
    return mapping

grouped_ranges = itertools.groupby(ranges, key=mergeable_key)

optimized_ranges = []

for (k, g) in grouped_ranges:
    group = list(g)
    if len(group) == 1:
        optimized_ranges.append(group[0])
        continue
    # Assert that nothing in the group has an associated unicode string.
    for g in group:
        if g[3] is not None and len(g[3]) > 2:
            assert not g[3][2].strip()
    # Assert that consecutive members of the group don't leave gaps in
    # the codepoint space.
    a, b = itertools.tee(group)
    next(b, None)
    for (g1, g2) in itertools.izip(a, b):
        last_char = int(g1[1], 16)
        next_char = int(g2[0], 16)
        if last_char + 1 == next_char:
            continue
        # There's a gap where surrogates would appear, but we don't have to
        # worry about that gap, as surrogates never appear in Rust strings.
        # Assert we're seeing the surrogate case here.
        assert last_char == 0xd7ff
        assert next_char == 0xe000
    first = group[0][0]
    last = group[-1][1]
    mapping = group[0][2]
    unicode_str = group[0][3]
    optimized_ranges.append((first, last, mapping, unicode_str))

for (first, last, mapping, unicode_str) in optimized_ranges:
    if unicode_str is not None:
        mapping += rust_slice(strtab_slice(unicode_str))
    print("    Range { from: '%s', to: '%s', mapping: %s }," % (escape_char(char(first)),
                                                                escape_char(char(last)),
                                                                mapping))

print("];\n")

def escape_str(s):
    return [escape_char(c) for c in s]

print("static STRING_TABLE: &'static str = \"%s\";"
      % '\\\n  '.join(itertools.chain(*[escape_str(s) for s in strtab.iterkeys()])))
