#ifndef _ACTION_4TO6_P4_
#define _ACTION_4TO6_P4_

#include "dash_headers.p4"

control action_4to6(inout headers_t hdr, inout metadata_t meta)
{
    apply {
        ipv4_t ipv4 = hdr.ip.ipv4;

        hdr.ip.ipv6.setValid();
        hdr.ip.ipv6.version = 6;
        hdr.ip.ipv6.traffic_class = 0;
        hdr.ip.ipv6.flow_label = 0;
        hdr.ip.ipv6.payload_length = ipv4.total_len - 20;
        hdr.ip.ipv6.hop_limit = ipv4.ttl;
        hdr.ip.ipv6.src_addr = ((bit<128>) ipv4.src_addr & ~meta.sip_4to6_encoding_mask) \
                            | meta.sip_4to6_encoding_value;
        hdr.ip.ipv6.dst_addr = ((bit<128>) ipv4.dst_addr & ~meta.dip_4to6_encoding_mask) \
                            | meta.dip_4to6_encoding_value;
        hdr.ip.ipv4.setInvalid();
        hdr.ethernet.ether_type = IPV6_ETHTYPE;
    }
}

#endif /* _ACTION_4TO6_P4_ */
