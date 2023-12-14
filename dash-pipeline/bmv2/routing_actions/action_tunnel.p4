#ifndef _ACTION_TUNNEL_P4_
#define _ACTION_TUNNEL_P4_

#include "dash_headers.p4"

control action_tunnel(inout headers_t hdr, inout metadata_t meta)
{
    action drop() {
        meta.pkt_meta.dropped = true;
    }

    action set_tunnel_underlay0(IPv4Address     tunnel_sip,
                                IPv4Address     tunnel_dip,
                                EthernetAddress tunnel_smac,
                                EthernetAddress tunnel_dmac) {
        meta.tunnel_0.tunnel_sip = tunnel_sip != 0 ? tunnel_sip : meta.tunnel_0.tunnel_sip;
        meta.tunnel_0.tunnel_dip = tunnel_dip != 0 ? tunnel_dip : meta.tunnel_0.tunnel_dip;
        meta.tunnel_0.tunnel_smac = tunnel_smac != 0 ? tunnel_smac : meta.tunnel_0.tunnel_smac;
        meta.tunnel_0.tunnel_dmac = tunnel_dmac != 0 ? tunnel_dmac : meta.tunnel_0.tunnel_dmac;
    }

    @SaiTable[name = "tunnel", api = "dash_tunnel"]
    table tunnel_underlay0 {
        key = {
            meta.tunnel_underlay0_id : exact;
        }

        actions = {
            set_tunnel_underlay0;
            drop;
        }
        const default_action = drop;
    }

    action set_tunnel_underlay1(IPv4Address     tunnel_sip,
                                IPv4Address     tunnel_dip,
                                EthernetAddress tunnel_smac,
                                EthernetAddress tunnel_dmac) {
        // FIXME: use underlay1_sip, etc
        meta.tunnel_0.tunnel_sip = tunnel_sip != 0 ? tunnel_sip : meta.tunnel_0.tunnel_sip;
        meta.tunnel_0.tunnel_dip = tunnel_dip != 0 ? tunnel_dip : meta.tunnel_0.tunnel_dip;
        meta.tunnel_0.tunnel_smac = tunnel_smac != 0 ? tunnel_smac : meta.tunnel_0.tunnel_smac;
        meta.tunnel_0.tunnel_dmac = tunnel_dmac != 0 ? tunnel_dmac : meta.tunnel_0.tunnel_dmac;
    }

    @SaiTable[name = "tunnel", api = "dash_tunnel"]
    table tunnel_underlay1 {
        key = {
            meta.tunnel_underlay1_id : exact;
        }

        actions = {
            set_tunnel_underlay1;
            drop;
        }
        const default_action = drop;
    }

    apply {
        if ((meta.tunnel_target & TUNNEL_UNDERLAY0) != 0) {
            tunnel_underlay0.apply();
        }

        if ((meta.tunnel_target & TUNNEL_UNDERLAY1) != 0) {
            tunnel_underlay1.apply();
        }
    }
}

#endif /* _ACTION_TUNNEL_P4_ */
