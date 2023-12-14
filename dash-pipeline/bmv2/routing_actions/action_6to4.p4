#ifndef _ACTION_6TO4_P4_
#define _ACTION_6TO4_P4_

#include "dash_headers.p4"

control action_6to4(inout headers_t hdr, inout metadata_t meta)
{
    apply {
        ipv6_t ipv6 = hdr.ip.ipv6;

        hdr.ip.ipv4.setValid();
        hdr.ip.ipv4.version = 4;
        hdr.ip.ipv4.ihl = 5;
        hdr.ip.ipv4.diffserv = 0;
        // FIXME: skip ipv6 option length ??
        hdr.ip.ipv4.total_len = 20 + ipv6.payload_length;
        hdr.ip.ipv4.identification = 1;
        hdr.ip.ipv4.flags = 0;
        hdr.ip.ipv4.frag_offset = 0;
        hdr.ip.ipv4.ttl = ipv6.hop_limit;
        hdr.ip.ipv4.protocol = ipv6.next_header;
        hdr.ip.ipv4.hdr_checksum = 0;
        hdr.ip.ipv4.src_addr = ((bit<32>) ipv6.src_addr & ~meta.sip_6to4_encoding_mask) \
                            | meta.sip_6to4_encoding_value;
        hdr.ip.ipv4.dst_addr = ((bit<32>) ipv6.dst_addr & ~meta.dip_6to4_encoding_mask) \
                            | meta.dip_6to4_encoding_value;
        hdr.ip.ipv6.setInvalid();
        hdr.ethernet.ether_type = IPV4_ETHTYPE;
    }
}

#endif /* _ACTION_6TO4_P4_ */
