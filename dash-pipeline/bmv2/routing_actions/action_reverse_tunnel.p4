#ifndef _ACTION_REVERSE_TUNNEL_P4_
#define _ACTION_REVERSE_TUNNEL_P4_

#include "dash_headers.p4"

control action_reverse_tunnel(inout headers_t hdr, inout metadata_t meta)
{
    apply {
        // No packet transformation so far
    }
}

#endif /* _ACTION_REVERSE_TUNNEL_P4_ */
