#ifndef _ACTION_NAT_P4_
#define _ACTION_NAT_P4_

#include "dash_headers.p4"

control action_nat(inout headers_t hdr, inout metadata_t meta)
{
    action do_nat(IPv4ORv6Address nat_sip,
                  IPv4ORv6Address nat_dip,
                  bit<1> ip_is_v6,
                  bit<16> nat_sport,
                  bit<16> nat_dport,
                  bit<16> nat_sport_base,
                  bit<16> nat_dport_base
                  ) {
        if (hdr.tcp.isValid()) {
            hdr.tcp.src_port = nat_sport + (hdr.tcp.src_port - nat_sport_base);
            hdr.tcp.dst_port = nat_dport + (hdr.tcp.dst_port - nat_dport_base);
        } else {
            hdr.udp.src_port = nat_sport + (hdr.udp.src_port - nat_sport_base);
            hdr.udp.dst_port = nat_dport + (hdr.udp.dst_port - nat_dport_base);
        }

        if (ip_is_v6 != 0) {
            hdr.ip.ipv6.src_addr = nat_sip;
            hdr.ip.ipv6.dst_addr = nat_dip;
        } else {
            hdr.ip.ipv4.src_addr = (bit<32>)nat_sip;
            hdr.ip.ipv4.dst_addr = (bit<32>)nat_dip;
        }
    }

    apply {
        do_nat(meta.nat.nat_sip,
               meta.nat.nat_dip,
               meta.nat.is_ipv6,
               meta.nat.nat_sport,
               meta.nat.nat_dport,
               meta.nat.nat_sport_base,
               meta.nat.nat_dport_base);
    }
}

#endif /* _ACTION_NAT_P4_ */
