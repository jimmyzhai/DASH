#ifndef _ACTION_STATICENCAP_P4_
#define _ACTION_STATICENCAP_P4_

#include "dash_headers.p4"

control action_staticencap(inout headers_t hdr, inout metadata_t meta)
{
    action drop() {
        meta.pkt_meta.dropped = true;
    }

    apply {
        if (meta.tunnel_0.tunnel_type == dash_encapsulation_t.VXLAN) {
            vxlan_encap(hdr,
                        meta.tunnel_0.tunnel_dmac,
                        meta.tunnel_0.tunnel_smac,
                        meta.tunnel_0.tunnel_dip,
                        meta.tunnel_0.tunnel_sip,
                        meta.nat.nat_dmac,
                        meta.tunnel_0.tunnel_vni);
        } else if (meta.tunnel_0.tunnel_type == dash_encapsulation_t.NVGRE) {
            nvgre_encap(hdr,
                        meta.tunnel_0.tunnel_dmac,
                        meta.tunnel_0.tunnel_smac,
                        meta.tunnel_0.tunnel_dip,
                        meta.tunnel_0.tunnel_sip,
                        meta.nat.nat_dmac,
                        meta.tunnel_0.tunnel_vni);
        } else {
            drop();
        }
    }
}

#endif /* _ACTION_STATICENCAP_P4_ */
