#ifndef _ACTION_TUNNEL_FROM_ENCAP_P4_
#define _ACTION_TUNNEL_FROM_ENCAP_P4_

#include "dash_headers.p4"

control action_tunnel_from_encap(inout headers_t hdr, inout metadata_t meta)
{
    apply {
        if (meta.tunnel_source == TUNNEL_UNDERLAY0) {
            if (meta.tunnel_target == TUNNEL_UNDERLAY0) {
                // FIXME: copy underlay encap
            } else if (meta.tunnel_target == TUNNEL_UNDERLAY1) {
                // FIXME: copy underlay encap
            }
        } else if (meta.tunnel_source == TUNNEL_UNDERLAY1) {
            if (meta.tunnel_target == TUNNEL_UNDERLAY0) {
                // FIXME: copy underlay encap
            } else if (meta.tunnel_target == TUNNEL_UNDERLAY1) {
                // FIXME: copy underlay encap
            }
        }
    }
}

#endif /* _ACTION_TUNNEL_FROM_ENCAP_P4_ */
